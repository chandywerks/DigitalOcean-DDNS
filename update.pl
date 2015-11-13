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

# Query the digital ocean API for the domain record
my $api = DomainsAPI->new( $cfg->{token} );
my $record = $api->getRecord( $cfg->{record}, $cfg->{domain} ) or die error( $log, DomainsAPI->errstr );

if( $record->{data} ne $ip ) {
	$api->setRecord( $record->{id}, $cfg->{domain}, $ip ) or die error( $log, DomainsAPI->errstr );
	$log->INFO($cfg->{domain}." A record \"".$cfg->{record}."\" changed from ".$record->{data}." to ".$ip);
}
