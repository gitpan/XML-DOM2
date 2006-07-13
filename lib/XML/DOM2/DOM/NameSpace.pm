package XML::DOM2::DOM::NameSpace;

use strict;
use Carp;

=head2 name

$name = $attribute->name;

Returns the attributes full name with namespace prefix.

=cut
sub name
{
	my ($self) = @_;
	my $prefix = $self->prefix;
	return ($prefix ? $prefix.':' : '').$self->localName;
}

=head2 localName

$name = $attribute->localName;

Returns the attribute name without name space prefix.

=cut
sub localName
{
	my ($self) = @_;
	confess "Does not have a self object for some reason\n" if not $self;
	return $self->{'name'};
}

=head2 prefix

$uri = $attribute->namespaceURI;

Returns the URI of the attributes namespace.

=cut
sub namespaceURI
{
	my ($self) = @_;
	return if not $self->namespace;
	return $self->namespace->ns_uri;
}

=head2 prefix

$prefix = $attribute->prefix;

Returns the attributes namespace prefix, returns undef if the namespace is the same as the owning element.

=cut 
sub prefix
{
	my ($self) = @_;
	return if not $self->namespace;
	if(not ref($self->namespace)) {
		warn "This name space is not right, I'd find out what gave it to you if I were you ".$self->namespace.':'.$self->localName.':'.$self." \n";
		return;
	}
	return $self->namespace->ns_prefix;
}

sub namespace
{
	my ($self) = @_;
	return $self->{'namespace'};
}

return 1;
