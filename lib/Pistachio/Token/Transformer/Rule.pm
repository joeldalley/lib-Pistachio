package Pistachio::Token::Transformer::Rule;
# ABSTRACT: express a token transformer rule as an object

use strict;
use warnings;
# VERSION

# @param string $type    object type
# @param hash    object properties
# @return Pistachio::Token::Transformer::Rule
sub new {
    my $type = shift;
    my $this = bless {@_}, $type;
}

# Simple getters.
sub type  { shift->{type} }
sub prec  { shift->{prec} }
sub succ  { shift->{succ} }
sub value { shift->{val} }
sub into  { shift->{into} }

1;

__END__

=head1 SYNOPSIS

 my $rule = Pistachio::Token::Transformer::Rule->new(
     type => 'Word',
     prec => [['Word::Reserved', 'package']],
     succ => [['Structure', ';']],
     into => 'Word::Package',
 );

 print $rule->type  # Word
 print $rule->into  # Word::Package
 print $rule->value # (Undef)

 print join ', ', @{$rule->prec}; # Word::Reserved, package
 print join ', ', @{$rule->succ}; # Structure, ;


 $rule = Pistachio::Token::Transformer::Rule->new(
     type => 'Symbol',
     val  => sub {shift =~ /^&/},
     into => 'Symbol::Sub'
 );

 print $rule->value->('&call_sub') # 1 (True)
 print $rule->value->('wtf&')      #   (False)

=cut

