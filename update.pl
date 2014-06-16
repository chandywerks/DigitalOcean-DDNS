#!/usr/bin/perl

use warnings;
use strict;

use LWP::UserAgent;
use File::Slurp;
use Log::Tiny;
use JSON::XS;
use FindBin;

my $log=Log::Tiny->new("$FindBin::Bin/log") or die Log::Tiny->errstr;
my $cfg=decode_json(read_file("$FindBin::Bin/config.json"));
