#!/usr/bin/perl

use strict;
use warnings;
use RRDs;

my $rrdfile = shift || '';
my $begin = 1265245200;
my $end   = 1268010000;

die qq(cannot read RRD file "$rrdfile"\n) unless -f $rrdfile;

my( $start, $step, $names, $data ) = RRDs::fetch $rrdfile, 'AVERAGE', '-s', $begin, '-e', $end;

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
