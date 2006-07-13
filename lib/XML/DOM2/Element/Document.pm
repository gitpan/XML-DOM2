package XML::DOM2::Element::Document;

=pod

=head1 NAME

XML::DOM2::Element::Document - DOM based document functions

=head1 SUMMARY

Provides the document element objec with the required DOM
interface for document wide element requests.

=head1 METHODS

=cut

use base "XML::DOM2::Element";
use Carp;

sub new
{
	my ($proto, %args) = @_;
	confess "Unable to create a new document element with no document!" if not $args{'document'};
	my $doc = $proto->SUPER::new($args{'documentTag'}, %args);
	return $doc;
}

sub _attribute_handle
{
	my ($self, $name, %opts) = @_;
	my $ns = $opts{'namespace'};
	if($name eq 'xmlns' or ($ns and $ns->ns_prefix eq 'xmlns')) {
		return XML::DOM2::Attribute::Namespace->new( %opts );
	}
	return $self->SUPER::_attribute_handle($name, %opts);
}

=head1 AUTHOR

Martin Owens, doctormo@postmaster.co.uk

=head1 SEE ALSO

perl(1), L<XML::DOM2>, L<XML::DOM2::Element>, L<XML::DOM2::DOM>

L<http://www.w3.org/TR/1998/REC-DOM-Level-1-19981001/level-one-core.html> DOM at the W3C

=cut

return 1;
