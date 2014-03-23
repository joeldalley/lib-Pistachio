package Pistachio::Supported;
# ABSTRACT: provides supported_languages() and supported_styles()

use strict;
use warnings;
# VERSION

use Pistachio::Tokenizer;
use Pistachio::Language;
use Pistachio::Html;

use JBD::Core::Exporter;
our @EXPORT_OK = qw(supported_languages supported_styles);

my @languages = qw(
    Perl5
    );

my @styles = qw(
    Github
    );

# @return array    list of supported languages
sub supported_languages {
    _eval(@$_) for &_pair_up;
    @languages;
}

# @return array    list of supported styles
sub supported_styles {
    _eval(@$_) for &_pair_up; 
    @styles;
}

# @param string $l    a language, e.g., 'Perl5'
# @param string $s    a style, e.g., 'Github'
sub _eval($$) {
    my ($l, $s) = @_;

    eval { Pistachio::Tokenizer->new(Pistachio::Language->new($l)) };
    die "Language `$l` should be supported -- $@" if $@;

    eval { Pistachio::Html->new($l, $s) };
    die "Style `$s` should be supported -- $@" if $@;
}

# @return array    pairs of [language, style]
sub _pair_up() {
    my @pairs;
    for my $l (@languages) { push @pairs, [$l, $_] for @styles }
    @pairs;
}

1;
