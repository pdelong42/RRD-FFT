#!/usr/bin/perl

=pod

In an attempt to make the C code as simple as possible, and not too closely
tied to any particular workflow, I've written this script to extract the data
from an RRD file, and print the output to several separate flat text files.
Each output file is a simple list containing the data extracted from a distinct
RRA within the original RRD file - there is a one-to-one correspondence between
output files and RRAs.

Each output file contains one field per line: the first line is a positive
integer representing a count of the number of data points, the second line is
an integer representing the sign exponent (either 1 or -1), and the remaining
lines are floating-point numbers (in scientific notation) representing the data
points.  The individual C code transforms are written to be able to read this
simple format, and output the same format.

It is envisioned that this is a stepping-stone to a more tightly integrated
process.  The intermediate step of writing to output files can be replaced by
starting the transform as an extrenal process, and piping the input to it over
a pipe.

Further integration can be obtained by reading the output from another pipe and
assembling it, as additional RRAs, into the original data structure generated
from the input XML.  That data structure can then be written out as a new XML
stream, and piped to RRDtool's "restore" factility, to create a new RRD file
with RRAs representing the transformed frequency-domain data, which can then be
used to generate graphs.

=cut

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
my $ref = XMLin $xml, ForceArray => 1, KeyAttr => [];

my @dsnames = map {
   @{ $ARG->{ name } }
}  @{ $ref->{ ds   } };

s{ \s+ }{}gx
   foreach @dsnames;

foreach( @{ $ref->{ rra } } ) {

   foreach( @{ cartesian_product( $ARG->{ database }, $ARG->{ pdp_per_row }, $ARG->{ cf } ) } ) { # footnote 3 #

      my %dslists;
      my $database = shift @$ARG;
      my $rows = $database->{ row };
      my $label = sprintf 'rra:steps=%s,cf=%s', @$ARG;

      $label =~ s{ \s+ }{}gx;

      push( @{ $dslists{ $ARG } }, scalar( @$rows ), 1 )
         foreach @dsnames; # footnote 2 #

      foreach( @$rows ) {

         my @tmplist = @dsnames;

         foreach( @{ $ARG->{ v } } ) {

            my $dsname = shift @tmplist;

            s{ \s+ }{}gx;

            push @{ $dslists{ $dsname } }, $ARG;
         }
      }

      foreach( @dsnames ) {

         my $hand;
         my $filename = "${label},ds=${ARG}.out";

         unless( open $hand, ">${filename}" ) {
            warn "unable to open $filename for writing - skipping";
            next;
         }

         print $hand "$ARG\n"
            foreach @{ $dslists{ $ARG } };

         close $hand
            or warn "unable to close ${filename}\n";
      }
   }
}

=pod

Footnote 1:

This was mostly lifted from a contributor at StackOverflow, with tweaks by me.
In a future commit, I should replace this with proper attribution to a link.

Footnote 2:

The second field represents the sign of the exponent in the transform (and thus
the direction of the transform).  This is needed for the DFT, but ignored for
the DHT.

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
maybe an optional field specifing what the row count would have been) - some
approaches to consider:

   - only operate on valid contiguous ranges of data, if NaNs can be kept to a
run at the end or beginning (or both) of the data, and put the same number of
NaNs back into the output dataset;

   - if there are isolated NaNs in the middle of the range of valid data (or
short runs), sample at a lower rate, perhaps at the heartbeat, or a larger
interval;


=cut
