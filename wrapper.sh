#!/bin/sh -x

./rrd.pl -f foo.rrd -t 12000 -e 1382559693 | ./test > bar.out
