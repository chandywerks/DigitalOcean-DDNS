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

sub error
{
	my ($log, $errstr)=@_;
	$log->ERROR($errstr);
	return $errstr;
}

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
	{ die error($log, "Unable to resolve external IP (".$res->status_line.")") }

# Query the digital ocean API for the domain record
my $api=DomainsApi->new({
			clientId	=> $cfg->{clientId},
			apiKey		=> $cfg->{apiKey}
		});

my $domain=$api->getDomain($cfg->{domainName}) or die error($log, DomainsApi->errstr);
my $record=$api->getRecord($domain->{id}, $cfg->{recordName}) or die error($log, DomainsApi->errstr);

if($record->{data} ne $ip)
{
	my $updatedRecord=$api->setRecord($domain->{id}, $record->{id}, $ip) or die error($log, DomainsApi->errstr);
	$log->INFO($domain->{name}." A record \"".$record->{name}."\" changed from ".$record->{data}." to ".$updatedRecord->{data});
}


