#!/usr/bin/perl

use strict;
use warnings;

use XML::Simple;
use Data::Dumper;
use List::Util;
use English qw( -no_match_vars );
use Getopt::Long qw( :config no_ignore_case );

sub cartesian_product { # footnote 1 #

   List::Util::reduce {

      return unless defined $a and defined $b; # just to get it to stop complaining
      return [
         map {
            my $item = $ARG;
            map [ @$ARG, $item ], @$a;
         } @$b
      ];

   } [[]], @ARG;
}

my $hand;
my $filename;
my $depth = 0;

local $/;

GetOptions(
   "depth+"     => \$depth,
   "filename=s" => \$filename,
) or die "getopts error";

open $hand, "/usr/bin/rrdtool dump $filename |"
   or die "could not rrddump $filename - aborting\n";

$Data::Dumper::Indent = 1;
$Data::Dumper::Maxdepth = $depth;

my $xml = readline $hand;
my $ref = XMLin $xml, ForceArray => 1;

my $dslist = [
   map {
      @{ $ARG->{ name } }
   }  @{ $ref->{ ds   } }
];

foreach( @{ $ref->{ rra } } ) {

   foreach( @{ cartesian_product( $ARG->{ database }, $ARG->{ pdp_per_row }, $ARG->{ cf } ) } ) {

      my $database = shift @$ARG;
      my $label = sprintf 'rra:steps=%s,cf=%s', @$ARG;

      $label =~ s{ \s+ }{}gx;

      print "$label\n";
      print "@$dslist\n";
      print( join( ' ', @{ $ARG->{ v } } ), "\n" )
         foreach @{ $database->{ row } };
   }
}

=pod

Footnote 1:

This was mostly lifted from a contributor at StackOverflow, with tweaks by me.
In a future commit, I should replace this with proper attribution to a link.

=cut
