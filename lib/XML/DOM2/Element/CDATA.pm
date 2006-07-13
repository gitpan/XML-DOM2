package XML::DOM2::Element::CDATA;

use base "XML::DOM2::Element";

use strict;
use warnings;

sub new
{
    my ($proto, $text, %args) = @_;
	$args{'text'} = $text;
    my $self = $proto->SUPER::new('cdata', %args);
	return $self;
}

sub xmlify
{
	my ($self, %p) = @_;
	my $sep = $p{'seperator'};
	my $text = $self->text;
	if($self->{'notag'}) {
		return $sep.'<![CDATA['.$text.']]>'.$sep;
	} elsif($self->{'noescape'}) {
		return $text;
	} else {
		return $self->_serialise_text($text);
	}
}

sub text
{
	my ($self) = @_;
	return $self->{'text'};
}

sub setData
{
	my ($self, $text) = @_;
	$self->{'text'} = $text;
}

sub appendData
{
	my ($self, $text) = @_;
	$self->{'text'} .= $text;
}  

sub _can_contain_elements { 0 }
sub _can_contrain_attributes { 0 }

return 1;
