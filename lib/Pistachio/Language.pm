package Pistachio::Language;
# ABSTRACT: provides an API for plugging arbitrary language tokenizers and stylizers into Pistachio

use strict;
use warnings;
# VERSION

# @param string $type Object type.
# @param string $lang A language identifier. E.g., 'Perl5'.
# @param hash %subs Map of {string => coderef}.
# @return Pistachio::Language
sub new {
    my ($type, $lang, %subs) = (shift, shift, @_);
    bless [
        $lang, 
        $subs{tokens},
        $subs{css},
        $subs{transform_rules} || sub {[]}
        ], $type;
}

# @param Pistachio::Language $this
# @return string A language identifier. E.g., 'Perl5'.
sub language { my $this = shift; $this->[0] }

# @param Pistachio::Language $this
# @param scalar/ref Input text.
# @return arrayref Array of Pistachio::Tokens.
sub tokens { my $this = shift; $this->[1]->(shift) }

# @param Pistachio::Language $this
# @param string A token type.
# @return string The CSS for the given type, or empty string.
sub css { my $this = shift; $this->[2]->(shift) }

# @param Pistachio::Language $this
# @return arrayref Transform rules (possibly empty).
sub transform_rules { my $this = shift; $this->[3]->() }

1;
