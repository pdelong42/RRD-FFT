RRD-FFT
=======

For a while now, I've had the idea that it might be really useful to take the
time series data from any RRD file, and run it through an FFT to see if any
patterns can be found in the frequency domain view of the data.

This is code I wrote to implement that idea, back in March of 2010 judging by
the original timestamps, and I apparently never put much work into it beyond
the proof-of-concept phase.  The little code that exists is a slapdash
collection of shell, Perl and C, for reasons of getting something up and
running quickly.  The heavy lifting is done by the C code, and it is envisioned
that the final product will be entirely done in C, using the appropriate
libraries.

I've put this here in an attempt to publicly shame myself into putting more
time into this project.  It's possible someone else has also done this, but I
haven't yet done a decent search to see if that's the case.  And while I should
do that, this exercise is partly for the sake of the learning process.

ToDo:
 - Write some useful documentation explaining what each part is for.
 - Make this more useful and usable beyond the proof-of-concept phase.
 - Figure-out how to handle NANs - it takes only one for an FFT to be useless.
 - Handle COUNTER and DERIVE types, not just GAUGE and ABSOLUTE.

Idea scratchpad:

 - For now, the most flexibility I envision for this is the ability to select
which RRA to perform the FFT on.  I suppose I could allow for the specification
of time ranges to operate on or what frequency ranges to output, but I haven't
yet put enough thought into it to what form that would take.

 - In my initial thoughts on this idea, I had planned to simply extract the RRD
data, transform it with an FFT, and stuff the new data into a new RRD file (or
a new RRA in the same RRD), so that I could leverage the existing graphing
features that RRDtool has built-in to it.  But there are problems with that,
mainly having to do with the way RRAs work.  To make it work that way would
involve major changes to the way RRDtool works, which I'm not sure I want to
do.

 - In the far future, could this possibly be tacked-onto RRDtool as another
kind of consolidation function?  Or should it instead only be done at graphing
time (you don't necessarily want to incur the overhead of an FFT every time a
CF gets run, which is presumably every time there is an update to the RRD).

Dependencies:

 - [RRDtool](http://www.rrdtool.org)
 - [FFTW library](http://www.fftw.org)
 - a C compiler (GCC, LLVM, ...)
 - Bourne Shell and Perl interpreters (but hopefully not for much longer)
