package Pistachio::Html;
# ABSTRACT: provides snippet(), which turns source code text into stylish HTML

use strict;
use warnings;
# VERSION

use Pistachio::Tokenizer;
use Pistachio::Language;
use HTML::Entities;
use Module::Load;
use Carp 'croak';

# @param string $type Object type.
# @param mixed $lang String: language, e.g., 'Perl5'.
#                    Object: A Pistachio::Language.
# @param string $style Style, e.g., 'Github'.
# @return Pistachio::Html
sub new {
    no strict 'refs';
    my $type = shift;
    my ($lang, $style) = (shift || '', shift || '');

    # Current package ability checker.
    my $ensure = sub {croak $_[1] if !__PACKAGE__->can($_[0])};

    # Common css package.
    #use Pistachio::Css::Github::Common;
    my $style_pkg = "Pistachio::Css::${style}::Common";
    (my $file = $style_pkg) =~ s{::}{/}g;
    require "$file.pm";
    #eval { load $style_pkg };
    #croak "Style `$style` not supported" if $@;
    #my $common_css = $style_pkg->new;
    my $common_css = $style_pkg->new;

    # Attempt onstruct a Pistachio::Lanauage, if not given one.
    # Note that currently only Perl5 has baked-in support.
    ref $lang eq 'Pistachio::Language' or do { 
        my $lang_pkg = "Pistachio::Css::${style}::${lang}";
        eval { load $lang_pkg };
        croak "Language `$lang` isn't supported" if $@;
        *token = *{"Pistachio::Css::${style}::${lang}::token"};

        eval {
            my $ns = 'Pistachio::Token';
            load "${ns}::Constructor::${lang}";
            load "${ns}::Transformer::${lang}";
            *text_to_tokens  = *{"${ns}::Constructor::${lang}::text_to_tokens"};
            *transform_rules = *{"${ns}::Transformer::${lang}::transform_rules"};
        };
        croak "Unsupported language `$lang`" if $@;

        # Common interface for the Tokenizer.
        $lang = Pistachio::Language->new($lang,
            tokens          => sub { text_to_tokens($_[0]) },
            transform_rules => sub { transform_rules() },
            css             => sub { token($_[0]) },
        );
    };

    bless [$lang, $common_css], $type;
}

# @param Pistachio::Html $this
# @return A Pistachio::Language
sub lang { shift->[0] }

# @param Pistachio::Html $this
# @return Pistachio::Css::x::Common Where x is the given style.
sub css { shift->[1] }

# @param Pistachio::Html $this
# @param scalarref $text    source code text
# @return string    line numbers div + source code div html
sub snippet {
    my ($this, $text) = @_;

    NUMBER_STRIP: my $num_strip = do {
        my @nums = 1 .. @{[split /\n/, $$text]};
        my $spec = '<div style="%s">%d</div>';
        my @divs = map sprintf($spec, $this->css->number_cell, $_), @nums;

        $spec = qq{<div style="%s">\n%s\n</div>\n};
        sprintf $spec, $this->css->number_strip, "@divs";
    };

    CODE_DIV: my $code_div = do {
        my $code = '';
        my $it = Pistachio::Tokenizer->new($this->lang)->iterator($text);

        while ($_ = $it->()) { 
            my $style = $this->lang->css($_->type);
            my $val = encode_entities $_->value;
            $code .= $style ? qq|<span style="$style">$val</span>|
                            : qq|<span>$val</span>|;
        }

        sprintf qq{<div style="%s">%s</div>}, $this->css->code_div, $code;
    };

    join "\n", '<div>', $num_strip, $code_div, '</div>',
               '<div style="clear:both"></div>';
}

1;

__END__

=head1 SYNOPSIS

 use Pistachio::Html;
 my $html = Pistachio::Html->new('Perl5', 'Github');

 my $scalar_ref = \"use strict; ...;";
 my $snip = $html->snippet($scalar_ref);

=cut
