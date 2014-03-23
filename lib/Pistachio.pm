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
 #
 #     (Currently)
 #     Languages: Perl5, JSON
 #     Styles:    Github
 #
 print Pistachio::supported;

 # Get a Pistachio::Html object
 my $handler = Pistachio::html_handler('Perl5', 'Github');

 # Perl source code text (in typical usage, read from a file)
 my $perl = join "\n", 'use strict;', 'package Foo::Bar', '...';

 # Github-like CSS-styled HTML snippet.
 my $snip = $handler->snippet(\$perl);

=cut 
