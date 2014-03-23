package Pistachio::Token;
# ABSTRACT: expresses a single source code language token as an object

use strict;
use warnings;
# VERSION

use constant {
    TYP => 0, 
    VAL => 1
};

# @param string $type    object type
# @param string $token_type    token type
# @param string  $token_value    token value
# @return Pistachio::Token
sub new {
    my $type = shift;
    my ($token_type, $token_value) = @_;
    bless [$token_type, $token_value], $type;
}

# @param object $this    a Pistachio::Token
# @param string [optional] $set    set to value, if any
# @return string    token type
sub type { 
    my ($this, $set) = @_;
    $this->[TYP] = $set if $set;
    $this->[TYP];
}

# @param Pistachio::Token
# @return string    token value
sub value { shift->[VAL] }

# @param Pistachio::Token
# @return int    1 if contained token type is Whitespace, or 0
sub whitespace { shift->type eq 'Whitespace' ? 1 : 0 }

# @param Pistachio::Token $this
# @param string $type    a type to match against
# @param coderef [optional] $val    a value match sub, or undef
# @return int    1 if token object matches $type and $val, or 0
sub match {
    my ($this, $type, $val) = @_;
    return 0 unless $this->type =~ /^$type/;
    return 1 unless defined $val;
    $val->($this->value) ? 1 : 0;
}

1;

__END__

=head1 SYNOPSIS

 use Pistachio::Token;
 my $type = 'Word::Package';
 my $value = 'package';
 my $token = Pistachio::Token->new($type, $value);

 print $token->type;       # Word::Package
 print $token->value;      # package
 print $token->whitespace; # 0

 print $token->match('Whitespace');    # 0
 print $token->match('Word::Package'); # 1

 my $cmp_type = 'Word::Package';
 my $cmp_val  = sub {$_[0] eq 'package'};
 print $token->match($cmp_type, $cmp_val); # 1

=cut
