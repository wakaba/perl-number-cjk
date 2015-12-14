use strict;
use warnings;
use Path::Tiny;
use lib glob path (__FILE__)->parent->parent->child ('t_deps/lib');
use lib glob path (__FILE__)->parent->parent->child ('t_deps/modules/*/lib');
use Test::X1;
use Test::More;
use Number::CJK::Parser;

use TestData;
our $Tests;

for my $input (keys %$Tests) {
  my $expected = $Tests->{$input};
  test {
    my $c = shift;
    my $result = parse_cjk_number $input;
    is $result, $expected;
    done $c;
  } n => 1, name => $input;
} # $test

run_tests;

=head1 LICENSE

Copyright 2015 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
