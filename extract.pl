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

my $handIn;
my $filename;
my $depth = 0;

local $/;

GetOptions(
   "depth+"     => \$depth,
   "filename=s" => \$filename,
) or die "getopts error";

open $handIn, "/usr/bin/rrdtool dump $filename |"
   or die "could not rrddump $filename - aborting\n";

$Data::Dumper::Indent = 1;
$Data::Dumper::Maxdepth = $depth;

my $xml = readline $handIn;
my $ref = XMLin $xml, ForceArray => 1;

my @dslist = map {
   @{ $ARG->{ name } }
}  @{ $ref->{ ds   } };

foreach( @{ $ref->{ rra } } ) {

   foreach( @{ cartesian_product( $ARG->{ database }, $ARG->{ pdp_per_row }, $ARG->{ cf } ) } ) {

      my @handOuts;
      my $database = shift @$ARG;
      my $label = sprintf 'rra:steps=%s,cf=%s', @$ARG;

      $label =~ s{ \s+ }{}gx;

      foreach( @dslist ) {

         s{ \s+ }{}gx;

         my $hand;
         my $filename = "${label},ds=${ARG}.out";

         if( open $hand, ">${filename}" ) {
            push @handOuts, $hand;
         } else {
            push @handOuts, undef;
            warn "unable to open $filename for writing - skipping";
         }
      }

      foreach my $row ( @{ $database->{ row } } ) {

         foreach( @handOuts ) {

            my $col = shift @{ $row->{ v } };
            next unless defined;
            print $ARG "$col\n";
         }
      }

      foreach( @handOuts ) {
         close $ARG
            or warn "unable to close $ARG\n";
      }
   }
}

=pod

Footnote 1:

This was mostly lifted from a contributor at StackOverflow, with tweaks by me.
In a future commit, I should replace this with proper attribution to a link.

=cut
