#!/usr/bin/perl

=pod

This is a pre-processor for the FFT.  It's meant to extract the time series
data from the RRD file, and output it in a text format which my C code can
parse.

The main reason this script exists is that I don't know how to call "rrdtool
fetch" from C yet.  And since the documentation for the API doesn't really
exist yet, I need to read through the rrdtool code to figure-out the interface,
which I haven't gotten around to doing yet.

Right now I call this from wrapper.sh, but there's no good reason not to call
the binary executable directly from here using Perl's facilities for that.  I
just chose what was easiest for me at the time.  That, and it was nice to have
the intermediate step, so that I could inspect the data for the sake of some
basic sanity-checking.

=cut

use strict;
use warnings;

use RRDs;
use English;
use Getopt::Long qw( :config no_ignore_case );

my( $rrdfile, $timespan );

my $end = time();

GetOptions(
   'filename=s' => \$rrdfile,
   'timespan=s' => \$timespan,
   'end=s'      => \$end,
) or die "getopts error";

die qq(cannot read RRD file "$rrdfile" - aborting\n)
   unless -r $rrdfile;

die "no timespan specified - aborting\n"
   unless defined $timespan;

my $begin = $end - $timespan;

my( $start, $step, $names, $data ) = RRDs::fetch $rrdfile, 'AVERAGE', '-s', $begin, '-e', $end;

warn "sanity check info: start=$start (begin=$begin), step=$step, names=[@$names]\n";

printf "%s\n", scalar( @$data );

foreach my $ds ( @$data ) {

   foreach my $val ( @$ds ) {

      if( $val ) {
         print "$val 0 0 0 0\n";
      } else {
         print "0 0 0 0 0\n";
      }
   }
}
