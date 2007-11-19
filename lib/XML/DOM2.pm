package XML::DOM2;

use strict;
use warnings;

=head1 NAME

  XML::DOM2 - DOM controlled, strict XML module for extentable xml objects.

=head1 VERSION

Version 0.04 - 2007-11-19

=head1 SYNOPSIS

  my $xml = XML::DOM2->new( file => 'filename.xml' );
  my $xml = XML::DOM2->new( data => '<xml>data</xml>' );
  my $xml = XML::DOM2->new( fh   => $file_handle );

  $xml->getChildren();

=head1 DESCRIPTION

  XML::DOM2 is yet _another_ perl XML module.

  Features:

  * DOM Level2 Compilence in both document, elements and attributes
  * NameSpace control for elements and attributes
  * XPath (it's just one small method once you have a good DOM)
  * Extendability:
   * Document, Element or Attribute classes can be used as base class for other
     kinds of document, element or attribute.
   * Element and Attribute Handler allows element specific child elements and attribute objects.
   * Element and Attribute serialisation overiding.
  * Parsing with SAX (use XML::SAX::PurePerl for low dependancy installs)
  * Internal serialisation

=head1 METHODS

=cut

use vars qw($VERSION);
use base "XML::DOM2::DOM::Document";
use Carp;

# All unspecified Elements
use XML::DOM2::Element;
# Basic Element Types
use XML::DOM2::Element::Document;
use XML::DOM2::Element::Comment;
use XML::DOM2::Element::CDATA;

# XML Parsing
use XML::DOM2::Parser;
use XML::SAX::ParserFactory;

$VERSION = "0.04";

my %default_options = (
    # processing options
    printerror => 1,       # print error messages to STDERR
    raiseerror => 1,       # die on errors (implies -printerror)
    # rendering options
    indent     => "\t",    # what to indent with
    seperator  => "\n",    # element line (vertical) separator
    nocredits  => 0,       # enable/disable credit note comment
);

=head2 $class->new( file|data|fh )

  Create a new xml object, it will parse a file, data or a file handle if required or will await creation of nodes.

=cut
sub new
{
    my ($proto, %o) = @_;
    my $class = ref $proto || $proto;

	if($o{'file'} or $o{'fh'} or $o{'data'}) {
		return $class->parseDocument(%o);
	}

	my $self = bless \%o, $class;
    return $self;
}

=head2 $object->parseDocument( %p )

  Parse existing xml data into a document, inputs taken from ->new;

=cut
sub parseDocument
{
	my ($proto, %p) = @_;
	my $class = ref $proto || $proto;

	my $xml = $proto->createDocument( undef, 'newDocument' );
	my $handler = XML::DOM2::Parser->new( document => $xml );
	my $parser = XML::SAX::ParserFactory->parser( Handler => $handler );

	$parser->parse_uri($p{'file'}) if $p{'file'}; # URI
	$parser->parse_string($p{'data'}) if $p{'data'}; # STRING DATA
	$parser->parse_file($p{'fh'}) if $p{'fh'}; # FILE HANDLE

	return $xml;
} 

=head2 $object->xmlify( %options )

  $string = $xml->xmlify( %options );

  Returns xml representation of xml document.

=cut
sub xmlify
{
    my ($self,%attrs) = @_;
    my ($decl,$ns);

	my $sep = $attrs{'seperator'} || $self->{'seperator'} || "\n";
    unless ($self->{-nocredits}) {
        $self->documentElement->appendChild(
			$self->createComment( $self->_credit_comment ),
		);
    }

	my $xml = '';
	#write the xml header
	$xml .= $self->_serialise_header(
		seperator => $sep,
	);

	#and write the dtd if this is inline
	$xml .= $self->_serialise_doctype(
		seperator => $sep,
	) unless $self->{'inline'};

	$self->documentElement->setAttribute('xmlns', $self->namespace) if $self->namespace;
	$xml .= $self->documentElement->xmlify(
		namespace => $self->{'-namespace'},
		seperator => $sep,
		indent    => $self->{'-indent'},
	);
	# Return xml string
	return $xml;
}
*render=\&xmlify;
*to_xml=\&xmlify;
*serialise=\&xmlify;
*serialize=\&xmlify;


=head2 $object->extention()
	
  $extention = $xml->extention();

  Does not work, legacy option maybe enabled in later versions.

=cut
sub extension
{
    my ($self) = @_;
    return $self->{'-extension'};
}


=head1 OPTIONS

=head2 $object->namespace( $set )

  Default document name space

=cut
sub namespace  { shift->_option('namespace',  @_); }

=head2 $object->name( $set )

  Document localName

=cut
sub name       { shift->_option('name',       @_); }

=head2 $object->doctype()

  Document Type object

=cut
sub doctype    { shift->_option('doctype',    @_); }

=head2 $object->version()

  XML Version

=cut
sub version    { shift->_option('version',    @_); }

=head2 $object->encoding()

  XML Encoding

=cut
sub encoding   { shift->_option('encoding',   @_); }

=head2 $object->standalone()

 XML Standalone

=cut
sub standalone { shift->_option('standalone', @_); }

=head1 INTERNAL METHODS

=head2 _serialise_doctype

$xml->_serialise_doctype( seperator => "\n" );

Returns the document type in an xml header form.

=cut
sub _serialise_doctype
{
    my ($self, %p) = @_;
    my $sep = $p{'seperator'};
    my $type = $self->documentType;
	croak "Unable to serialise document, doctype is not defined" if not $type;

    my $id;
    if ($type->publicId) {
		$id = 'PUBLIC "'.$type->publicId.'"';
		$id .= ($type->systemId ? $sep.' "'.$type->systemId.'"' : '');   
    } else {
		warn "I'm not returning a doctype because there is n public id: ".$type->publicId;
		return '';
	}

#	if($type->systemId) {
#		$id = ' SYSTEM "'.$type->systemId.'"';
#	}
	my $extension = $self->_serialise_extension( seperator => $sep );
	$type = $type->name;
	warn "no TYPE defined!" if not defined($type);
	warn "no id!" if not defined($id);
	return $sep."<!DOCTYPE $type $id$extension>";
}

=head2 _serialise_extention

$xml->_serialise_extention( seperator => "\n" );

Returns the document extentions.

=cut
sub _serialise_extension
{
	my ($self, %p) = @_;
	my $sep = $p{'seperator'};
	my $ex = '';
	if ($self->extension) {
		$ex .= $sep.$self->extension.$sep;
		$ex = " [".$sep.$ex."]";
	}
	return $ex;
}

=head2 _serialise_header

$xml->_serialise_header( );

The XML header, with version, encoding and standalone options.

=cut
sub _serialise_header
{
	my ($self, %p) = @_;

	my $version= $self->{'version'} || '1.0';
	my $encoding = $self->{'encoding'} || 'UTF-8';
	my $standalone = $self->{'stand_alone'} ||'yes';

	return '<?xml version="'.$version.'" encoding="'.$encoding.'" standalone="'.$standalone.'"?>';
}

=head2 _element_handle

$xml->_element_handle( $type, %element-options );

Returns an XML element based on $type, use to extentd element capabilties.

=cut
sub _element_handle
{
	my ($self, $type, %opts) = @_;
	confess "Element handler with no bleedin type!!" if not $type;
	if($type eq '#document' or $type eq $self->_document_name) {
		$opts{'documentTag'} = $type if $type ne '#document';
		return XML::DOM2::Element::Document->new(%opts);
	} elsif($type eq '#comment') {
		return XML::DOM2::Element::Comment->new( delete($opts{'text'}), %opts);
	} elsif($type eq '#cdata-entity') {
		return XML::DOM2::Element::CDATA->new(%opts);
	}
	return XML::DOM2::Element->new( $type, %opts );
}

=head2 $object->_option( $name[, $data] )

  Set or get the required option.

=cut
sub _option
{
	my ($self, $option, $set) = @_;
	if(defined($set)) {
		$self->{$option} = $set;
	}
	return $self->{$option};
}

=head2 $object->_can_contain_element()

  Does this node support element children.

=cut
sub _can_contain_element { 1 }


=head2 $object->_document_name()

  Returns the doctype name or 'xml' as default, can be extended.

=cut
sub _document_name { return shift->doctype->name || 'xml'; }

=head2 $object->_credit_comment()

  Returns the comment credit used in the output

=cut
sub _credit_comment { "\nGenerated using the Perl XML::DOM2 Module V$VERSION\nWritten by Martin Owens\n" }


=head1 COPYRIGHT

Martin Owens, doctormo@cpan.org

=head1 CREDITS

Based on SVG.pm by Ronan Oger, ronan@roasp.com

=head1 SEE ALSO

perl(1),L<XML::DOM2>,L<XML::DOM2::Parser>

=cut 
1;
