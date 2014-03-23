package Pistachio::Token::Constructor::Perl5;
# ABSTRACT: provides text_to_tokens(), which turns source code text into an array of Pistachio::Tokens

use strict;
use warnings;
# VERSION

use Pistachio::Keywords::Perl5 'is_keyword';
use Pistachio::Token;
use PPI::Tokenizer;

# @param scalarref    reference to text
# @return arrayref    Pistachio::Token array
sub text_to_tokens {
    my $ppi = PPI::Tokenizer->new(shift);

    my @tokens;
    while (my $token = $ppi->get_token) {
        (my $type = ref $token) =~ s/PPI::Token:://o;
        my $val = $token->{content};

        $type eq 'Word' and do {
            my $is = is_keyword $val;
            $type .= '::' . ($is ? 'Reserved' : 'Defined');
        };

        push @tokens, Pistachio::Token->new($type, $val);
    }
    \@tokens;
}

1;

__END__

=head1 SYNPOSIS

 use Pistachio::Token::Constructor::Perl5 'text_to_tokens';
 my $tokens = text_to_tokens(\"use strict; ...;");

 for my $token (@$tokens) {
     print $token->type, ': ', $token->value, "\n";
 }

=head1 NOTES

This module uses L<PPI::Tokenizer> to tokenize Perl5 source code.

=cut
