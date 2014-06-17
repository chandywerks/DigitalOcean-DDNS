package DomainsApi;
use strict;
use vars qw($errstr);

use LWP::UserAgent;
use JSON::XS;

use Data::Dumper;

$errstr="foo";
sub new
{
	my ($class, $args)=@_;
	my $self={
		clientId	=> $args->{clientId},
		apiKey		=> $args->{apiKey}
	};

	$self->{url}="https://api.digitalocean.com/v1/domains";
	$self->{ua}=LWP::UserAgent->new;

	return bless($self, $class);
}
sub getDomain
{
	# Returns a hash table containing info about the matching domain name
	# if no match or an error returns undef and sets the error string with a message
	my ($self, $domainName)=@_;
	my $domainsReq=HTTP::Request->new(
			GET => $self->{url}."?client_id=".$self->{clientId}."&api_key=".$self->{apiKey}
	);
	my $res=$self->{ua}->request($domainsReq);
	if($res->is_success)
	{ 
		my $domains=decode_json($res->decoded_content);

		foreach my $domain(@{$domains->{domains}})
			{ return $domain if($domain->{name} eq $domainName) }

		return _error("Could not find domain: ".$domainName)
	}
	else
		{ return _error("API call failed: ".$res->status_line) }
}
sub getRecord
{

}
sub setIp
{

}
sub _error
{
	($errstr)=@_;
	return undef;
}
sub errstr { return $errstr }
1;
