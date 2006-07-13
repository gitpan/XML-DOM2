package XML::DOM2::Attribute;

use base "XML::DOM2::DOM::Attribute";

use strict;
use warnings;
use Carp;

sub new
{
	my ($proto, %opts) = @_;
	croak "Attribute must have a name!" if not $opts{'name'};
	croak "Attribute must have an owner" if not $opts{'owner'};
	my $value = delete($opts{'value'});
	my $self = bless \%opts, $proto;
	$self->deserialise( $value ) if defined($value);
	return $self;
}

=head2 value

$value = $attribute->value;

Returns the serialised value within this attribute.

=cut
sub value
{
	my ($self) = @_;
	return $self->serialise;
}

=head2 serialise

$value = $attribute->serialise;

Returns the serialised value for this attribute.

=cut
sub serialise
{
	my ($self) = @_;
	return $self->{'value'};
}

=head2 deserialise

$attribute->deserialise($value);

Sets the attribute value to $value, does any deserialisation too.

=cut
sub deserialise
{
	my ($self, $value) = @_;
	$self->{'value'} = $value;
}

=head2 serialise_full

$attr = $attribute->serialise_full;

Returns the serialised name and value for this attribute.

=cut
sub serialise_full
{
	my ($self) = @_;
	my $value = $self->value;
	$value = '~undef~' if not defined($value);
	return $self->name.'="'.$value.'"';
} 

sub document
{
	my ($self) = @_;
	warn "No owner element\n" if not $self->ownerElement;
	return undef if not $self->ownerElement;
	return $self->ownerElement->document;
}

sub delete {}

return 1;
