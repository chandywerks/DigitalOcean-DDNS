#!/usr/bin/perl

use warnings;
use strict;

use LWP::UserAgent;
use JSON::XS;
use File::Slurp;
use FindBin;
use Log::Tiny;

my $log=Log::Tiny->new("$FindBin::Bin/log") or die Log::Tiny->errstr;
my $cfg=decode_json(read_file("$FindBin::Bin/config.json"));

# Get our global IP
my $ua=LWP::UserAgent->new;
my $req=HTTP::Request->new(GET => "http://ipinfo.io/ipp");
my $res=$ua->request($req);
my $ip;

if($res->is_success)
	{ chomp($ip=$res->decoded_content) }
else
	{ $log->ERROR("Unable to resolve external IP (".$res->status_line.")") && exit}

print "IP: $ip\n";

# Query the digital ocean API for the domain record
my $record=Record->new($cfg);

# if($record->getIp ne $ip)
# {
# 	$record->setIp($ip);
# 	$log->INFO("DNS 'A' record \"".$cfg->{recordName}."\" changed to ".$ip);
# }

package Record;

sub new
{
	my ($class, $args)=@_;
	my $self={};

	$self->{_ua}=LWP::UserAgent->new;
}
sub getIp
{

}
sub setIp
{

}
1;
