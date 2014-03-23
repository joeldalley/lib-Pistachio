use strict;
use warnings;

use Test::More tests => 6;

BEGIN {
    use_ok('Pistachio::Css::Github::Perl5');
    use_ok('Pistachio::Css::Github::Common', 'code_div');
    no strict 'refs';
    *token = *Pistachio::Css::Github::Perl5::token;
}

my $expect = "font-family:Consolas,'Liberation Mono',Courier,monospace;"
           . 'padding:0 8px 0 11px;white-space:pre;font-size:13px;'
           . 'line-height:18px;float:left';

ok(&code_div eq $expect, 
   'Pistachio::Css::Style::Github::code_div() returns expected string');

my %expect = (
    'Symbol::Sub' => 'color:#333',
    'Operator::Dereference' => 'color:#333;font-weight:bold',
    'Dont::Have' => undef,
    );

while (my ($type, $style) = each (%expect)) {
    if (defined $style) {
        ok(token($type) eq $style, "Token style for `$type`");
    }
    else {
        ok(token($type) eq '', "Empty style for unknown type `$type`");
    }
}

done_testing;
