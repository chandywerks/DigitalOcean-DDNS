#!/usr/bin/perl

use warnings;
use strict;

use LWP::UserAgent;
use JSON::XS;
use File::Slurp;
use FindBin;
use Log::Tiny;

use lib "$FindBin::Bin/lib";
use DomainsAPI;

sub error {
	my ($log, $errstr) = @_;
	$log->ERROR($errstr);
	return $errstr;
}

my $log = Log::Tiny->new("$FindBin::Bin/log") or die Log::Tiny->errstr;
my $cfg = decode_json(read_file("$FindBin::Bin/config.json"));

# Get our global IP
my $ua	= LWP::UserAgent->new;
my $req = HTTP::Request->new(GET => "http://ipinfo.io/ip");
my $res = $ua->request($req);
my $ip;

if( $res->is_success ) {
	chomp($ip=$res->decoded_content);
} else {
	die error($log, "Unable to resolve external IP (".$res->status_line.")");
}

my $api = DomainsAPI->new( $cfg->{token} );

foreach my $domain ( @{ $cfg->{domains} } ) {

	# If just a single record was defined push it in to records array
	if( defined $domain->{record} ) {
		push( @{ $domain->{records} }, $domain->{record} );
	}

	foreach my $record_name ( @{ $domain->{records} } ) {
		# Query the digital ocean API for the domain A record
		my $record = $api->getRecord( $record_name, $domain->{name} );

		if( !$record ) {
			error( $log, "Unable to get " . $record_name . "record for " . $domain->{name} . ": " . DomainsAPI->errstr );

			next;
		}

		# Update the A record if the IP has changed
		if( $record->{data} ne $ip ) {
			$api->setRecord( $record->{id}, $domain->{name}, $ip ) or die error( $log, DomainsAPI->errstr );
			$log->INFO($domain->{name}." A record \"".$record_name."\" changed from ".$record->{data}." to ".$ip);
		}
	}

}
