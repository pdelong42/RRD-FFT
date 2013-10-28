#!/bin/sh

#start=1267920360
#  end=1268010360

start=1265245200
  end=1268010000

#start=1233450000
#  end=1268010000

/usr/bin/rrdtool graph ${1/rrd/png} -a PNG -i -w 800 -h 200 -s $start -e $end DEF:graph1=${1}:ds0:AVERAGE LINE1:graph1#0000FF
#/usr/bin/rrdtool fetch ${1} AVERAGE -s $start -e $end
