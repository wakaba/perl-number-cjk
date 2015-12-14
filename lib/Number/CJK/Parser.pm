package Number::CJK::Parser;
use strict;
use warnings;
our $VERSION = '1.0';
use Carp;

use Number::CJK::_Classes;
our $Digit;
our $TenQuadrillion;
our $Trillion;
our $HundredMillion;
our $TenThousand;
our $Thousand;
our $Hundred;
our $Ten;
our $MultipleTens;
our $Value;

our @EXPORT;

sub import ($;@) {
  my $from_class = shift;
  my ($to_class, $file, $line) = caller;
  no strict 'refs';
  for (@_ ? @_ : @{$from_class . '::EXPORT'}) {
    my $code = $from_class->can ($_)
        or croak qq{"$_" is not exported by the $from_class module at $file line $line};
    *{$to_class . '::' . $_} = $code;
  }
} # import

sub _parse_small ($) {
  if ($_[0] =~ s/^((?:$Digit){2,4})//o) {
    return 0 + join '', map {
      $Value->{$_};
    } split //, $1;
  }
  my $value = 0;
  my $removed = 0;
  if ($_[0] =~ s/^($Digit)($Thousand)//o) {
    $value += $Value->{$1} * $Value->{$2};
    $removed = 1;
  } elsif ($_[0] =~ s/^($Thousand)//o) {
    $value += $Value->{$1};
    $removed = 1;
  }
  if ($_[0] =~ s/^($Digit)($Hundred)//o) {
    $value += $Value->{$1} * $Value->{$2};
    $removed = 1;
  } elsif ($_[0] =~ s/^($Hundred)//o) {
    $value += $Value->{$1};
    $removed = 1;
  }
  if ($_[0] =~ s/^($Digit)($Ten)//o) {
    $value += $Value->{$1} * $Value->{$2};
    $removed = 1;
  } elsif ($_[0] =~ s/^($Ten|$MultipleTens)//o) {
    $value += $Value->{$1};
    $removed = 1;
  }
  if ($_[0] =~ s/^($Digit)//o) {
    $value += $Value->{$1};
    $removed = 1;
  }
  return undef if not $removed;
  return $value;
} # _parse_small

sub _parse_large ($) {
  my $value = 0;
  my $v;
  if ($_[0] =~ s/^((?:$Digit){5,})//o) {
    $v = 0 + join '', map {
      $Value->{$_};
    } split //, $1;
  } else {
    $v = &_parse_small;
  }
  return undef if not defined $v;
  if ($_[0] =~ s/^($TenQuadrillion)//o) {
    $value += $v * $Value->{$1};
    $v = &_parse_small;
    return $value if not defined $v;
  }
  if ($_[0] =~ s/^($Trillion)//o) {
    $value += $v * $Value->{$1};
    $v = &_parse_small;
    return $value if not defined $v;
  }
  if ($_[0] =~ s/^($HundredMillion)//o) {
    $value += $v * $Value->{$1};
    $v = &_parse_small;
    return $value if not defined $v;
  }
  if ($_[0] =~ s/^($TenThousand)//o) {
    $value += $v * $Value->{$1};
    $v = &_parse_small;
    return $value if not defined $v;
  }
  $value += $v;
  return $value;
} # _parse_large

push @EXPORT, qw(parse_cjk_number);
sub parse_cjk_number ($) {
  my $input = $_[0];
  return undef if not length $input;
  my $value = _parse_large $input;
  return undef if not defined $value;
  return undef if length $input;
  return $value;
} # parse_cjk_number

1;

=head1 LICENSE

Copyright 2015 Wakaba <wakaba@suikawiki.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
