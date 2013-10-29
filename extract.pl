#!/usr/bin/perl

use strict;
use warnings;

use List::Util;
use XML::Simple;
use Data::Dumper;
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

   foreach( @{ cartesian_product( $ARG->{ database }, $ARG->{ pdp_per_row }, $ARG->{ cf } ) } ) { # footnote 3 #

      my @handOuts;
      my $database = shift @$ARG;
      my $rows = $database->{ row };
      my $label = sprintf 'rra:steps=%s,cf=%s', @$ARG;

      $label =~ s{ \s+ }{}gx;

      foreach( @dslist ) {

         s{ \s+ }{}gx;

         my $hand;
         my $filename = "${label},ds=${ARG}.out";

         if( open $hand, ">${filename}" ) {
            push @handOuts, $hand;
            print $hand scalar( @$rows ), " 1\n"; # footnote 2 #
         } else {
            push @handOuts, undef;
            warn "unable to open $filename for writing - skipping";
         }
      }

      foreach my $row ( @$rows ) {

         foreach( @handOuts ) {

            my $v = shift @{ $row->{ v } };

            next unless defined;
            $v =~ s{ \s+ }{}gx;
            print $ARG "$v\n";
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

Footnote 2:

The second field represents the sign of the exponent in the transform (and thus
the direction of the transform).

Footnote 3:

This is overkill.  Chances are this product will never result in more than one
item.  The only reason I'm doing this is because each of those is an array
reference, which could possibly contain more than one element (unlikely).  And
the only reason for *that* is because I enabled ForceArray.  And you ask: Why
did I do that?  Because I wanted to be able to treat the data structure in a
consistent manner.  Normally (without ForceArray enabled), XML::Simple will
take a shortcut when there is only one element, and that has to be handled
differently.  And not knowing ahead of time which way to traverse the data
structure would actually make this more complicated (and probably would still
require the cartesian product anyway).  So yes, this way is ultimately simpler,
believe it or not.

But yes, the code is ugly - I make no excuses for it.

ToDo:

 - bail-out if the DS is anything other than GAUGE or ABSOLUTE (ultimately, we
want to handle DERIVE and COUNTER types as well, but not yet);

 - weed-out NANs at this stage, and update the row count accordingly (with
maybe an optional field specifing what the row count would have been);

=cut
