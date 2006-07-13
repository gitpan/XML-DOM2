package XML::DOM2::DOM::Attribute;

use base "XML::DOM2::DOM::NameSpace";

use strict;
use warnings;

sub ownerElement
{
	return $_[0]->{'owner'};
}

return 1;
