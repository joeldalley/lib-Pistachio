package Pistachio;
# ABSTRACT: turns source code into stylish HTML

use strict;
use warnings;
# VERSION

use Module::Load;

# @return string    supported languages and styles message
sub supported() {
    my @import = qw(supported_languages supported_styles);
    load 'Pistachio::Supported', @import;

    my $out = "\nSupported Languages:\n";
    $out .= "\t - $_\n" for &supported_languages;

    $out .= "\nSupported Styles:\n";
    $out .= "\t - $_\n" for &supported_styles;
    $out .= "\n";

    $out;
}

# @param string $lang    a language, e.g., 'Perl5'
# @param string $style    a style, e.g., 'Github'
sub html_handler($$) {
    my ($lang, $style) = @_;
    load 'Pistachio::Html';
    Pistachio::Html->new($lang, $style);
}

1;

__END__

=head1 SYNOPSIS

 use Pistachio;

 # List supported languages and styles.
 print Pistachio::supported;

 # Get a Pistachio::Html object
 my $handler = Pistachio::html_handler('Perl5', 'Github');

 # Perl source code text (in typical usage, read from a file)
 my $perl = join "\n", 'use strict;', 'package Foo::Bar', '...';

 # Github-like CSS-styled HTML snippet.
 my $snip = $handler->snippet(\$perl);

=head1 ROLL YOUR OWN LANGUAGE SUPPORT

Currently, only Perl 5 support is baked into Pistachio (via L<PPI::Tokenizer>). 

However, using L<Pistachio::Language>, you can roll your own support for any language, as long as you can provide two subroutines. They are:

=over

=item *

First, a subroutine that returns Pistachio::Tokens for that language.

=item *

And second, a subroutine that maps those tokens' types to CSS style definitions.

=back

=head2 Generate HTML From Tokenized JSON

Using modules:

=over

=item *

L<Pistachio::Language> 

=item *

L<https://github.com/joeldalley/lib-JBD> (JBD::JSON).

=back

Providing a Pistachio::Language that knows how to parse and style arbitrary tokens allows the Pistachio core to render stylish HTML for those tokens.

In this example, we use JBD::JSON to parse JSON text, then map those tokens to Pistachio::Tokens. 
And we map the token types parsing with JBD::JSON produces to CSS style definitions.

 use Pistachio;
 use Pistachio::Token;
 use Pistachio::Language;
 use JBD::JSON 'parse';

 # Argument: JSON input text. Returns arrayref of Pistachio::Tokens.
 my $tokens = sub {
     my $tokens = std_parse 'json_text', $_[0];
     [map Pistachio::Token->new($_->type, $_->value), @$tokens];
 };

 # Argument: a token type. Returns corresponding CSS definition.
 my $css = sub {
     my %type_to_style = (
         JsonNum           => 'color:#008080',
         JsonNull          => 'color:#000',
         JsonBool          => 'color:#000',
         JsonString        => 'color:#D14',
         JsonColon         => 'color:#333',
         JsonComma         => 'color:#333',
         JsonSquareBracket => 'color:#333',
         JsonCurlyBrace    => 'color:#333',
         );
     $type_to_style{$_[0] || ''} || '';
 },

 # Construct a Pistachio::Html, loaded with our JSON language object.
 my $lang = Pistachio::Language->new(
     'JSON', 
     tokens => $tokens, 
     css    => $css
 );
 my $handler = Pistachio::html_handler($lang, 'GitHub');

 # Now Pistachio understands how to convert JSON input texts 
 # into Github-styled HTML output. Proceed as in the synopsis:

 my $json = join "\n", '{', '"key1":"value1", ..., '}';
 my $snip = $handler->snippet(\$json);

=cut
