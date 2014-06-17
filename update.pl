#!/usr/bin/perl

use warnings;
use strict;

use LWP::UserAgent;
use JSON::XS;
use File::Slurp;
use FindBin;
use Log::Tiny;

use lib "$FindBin::Bin/lib";
use DomainsApi;

use Data::Dumper;

my $log=Log::Tiny->new("$FindBin::Bin/log") or die Log::Tiny->errstr;
my $cfg=decode_json(read_file("$FindBin::Bin/config.json"));

# Get our global IP
my $ua=LWP::UserAgent->new;
my $req=HTTP::Request->new(GET => "http://ipinfo.io/ip");
my $res=$ua->request($req);
my $ip;

if($res->is_success)
	{ chomp($ip=$res->decoded_content) }
else
	{ $log->ERROR("Unable to resolve external IP (".$res->status_line.")") && exit}

print "IP: $ip\n";

# Query the digital ocean API for the domain record
my $api=DomainsApi->new({
			clientId	=> $cfg->{clientId},
			apiKey		=> $cfg->{apiKey}
		});

my $domain=$api->getDomain($cfg->{domainName}) or die DomainsApi->errstr;

#print "IP: ".$record->getIp."\n";

# if($record->getIp ne $ip)
# {
# 	$record->setIp($ip);
# 	$log->INFO("DNS 'A' record \"".$cfg->{recordName}."\" changed to ".$ip);
# }
