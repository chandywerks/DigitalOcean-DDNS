package DomainsAPI;
use strict;
use vars qw($errstr);

use LWP::UserAgent;
use JSON::XS;

$errstr = "";

sub new {
	my ($class, $token) = @_;

	my $self = {
		token => $token,
		url   => "https://api.digitalocean.com/v2/domains",
		ua    => LWP::UserAgent->new()
	};

	return bless($self, $class);
}

sub getRecord {
	my ($self, $recordName, $domainName) = @_;

	my $records = $self->_apicall('GET', $self->{url}."/".$domainName."/records") or return undef;

	foreach my $record (@{ $records->{domain_records} }) {
		if ( $record->{name} eq $recordName && $record->{type} eq "A" ) {
			return $record;
		}
	}

	return _error("Could not find record $recordName for $domainName");
}

sub setRecord {
	my ($self, $recordId, $domainName, $ip) = @_;
	return $self->_apicall('PUT', $self->{url}."/".$domainName."/records/".$recordId, { data => $ip });
}

sub _apicall {
	my ($self, $method, $uri, $content) = @_;

	my $req = HTTP::Request->new( $method => $uri );
	$req->header(
		'Content-Type'  => 'application/json',
		'Authorization' => "Bearer $self->{token}"
	);

	if( defined $content ) {
		$req->content( encode_json( $content ) );
	}

	my $res = $self->{ua}->request($req);

	return $res->is_success ? decode_json($res->decoded_content) : _error("Digital Ocean API call failed: ".$res->status_line);
}

sub _error {
	($errstr) = @_;
	return undef;
}

sub errstr { return $errstr }
1;
