package DomainsApi;
use strict;
use vars qw($errstr);

use LWP::UserAgent;
use JSON::XS;

$errstr="";

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
	# Returns a DomainsApi::Domain object for the requested domain name
	my ($self, $domainName)=@_;

	my $domains=$self->_apicall($self->{url}."?client_id=".$self->{clientId}."&api_key=".$self->{apiKey}) or return undef;

	foreach my $domain(@{$domains->{domains}})
		{ return $domain if($domain->{name} eq $domainName) }

	return _error("Could not find domain: ".$domainName);
}
sub getRecord
{
	my ($self, $domainId, $recordName)=@_;
	my $records=$self->_apicall($self->{url}."/".$domainId."/records?client_id=".$self->{clientId}."&api_key=".$self->{apiKey}) or return undef;

	foreach my $record(@{$records->{records}})
		{ return $record if ($record->{name} eq $recordName) }

	return _error("Could not find record: ".$recordName);
}
sub setRecord
{
	my ($self, $domainId, $recordId, $ip)=@_;
	my $record=$self->_apicall($self->{url}."/".$domainId."/records/".$recordId."/edit?client_id=".$self->{clientId}."&api_key=".$self->{apiKey}."&record_type=A&data=".$ip) or return undef;
	return $record->{record};

}
sub _apicall
{
	my ($self, $uri)=@_;
	my $req=HTTP::Request->new(GET => $uri);
	my $res=$self->{ua}->request($req);

	return $res->is_success?decode_json($res->decoded_content):_error("API call failed: ".$res->status_line);
}
sub _error
{
	($errstr)=@_;
	return undef;
}
sub errstr { return $errstr }
1;
