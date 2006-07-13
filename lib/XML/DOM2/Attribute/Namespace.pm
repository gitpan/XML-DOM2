package XML::DOM2::Attribute::Namespace;

use base "XML::DOM2::Attribute";

use strict;
use warnings;
use Carp;

sub new
{
	my ($proto, %opts) = @_;
	return $proto->SUPER::new(%opts);
}

sub serialise
{
	my ($self) = @_;
	my $result = $self->{'value'};
	return $result;
}

sub deserialise
{
	my ($self, $uri) = @_;
	if($self->{'value'}) {
		$self->document->removeNamespace($self);
	}
	$self->{'value'} = $uri;
	$self->document->addNamespace($self);
	if($self->name eq 'xmlns') {
		$self->document->namespace($uri);
	}
	return $self;
}

sub ns_prefix
{
	my ($self) = @_;
	return $self->localName;
}

sub ns_uri
{
	my ($self) = @_;
	return $self->serialise;
}

sub delete
{
	my ($self) = @_;
	# Make sure we remove this namespace from
	# the document when we remove the namespace attribute
	$self->document->removeNamespace($self);
}

return 1;
