package XML::DOM2::Element::Comment;

use base "XML::DOM2::Element";

use strict;
use warnings;

sub new
{
    my ($proto, $text, %args) = @_;
	$args{'text'} = $text;
    my $self = $proto->SUPER::new('comment', %args);
	return $self;
}

sub xmlify
{
	my ($self, %p) = @_;
	my $sep = $p{'seperator'} || "\n";
	my $indent = ($p{'indent'} || '  ') x ( $p{'level'} || 0 );
	my $text = $self->{'text'};
	$text =~ s/$sep/$sep$indent/g;
	return $sep.$indent.'<!--'.$text.'-->';
}

sub text
{
	my ($self) = @_;
	return $self->{'text'} || '';
}

sub setComment
{
	my ($self, $text) = @_;
	$self->{'text'} = $text;
}

sub appendComment
{
	my ($self, $text) = @_;
	$self->{'text'} .= $text;
}

sub _can_contain_elements { 0 }

return 1;
