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
