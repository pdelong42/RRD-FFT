#include <math.h>
#include <fftw3.h>
#include <stdlib.h>

int main() {

   int n, i, sign;
   double sqrtn;

   scanf( "%20i %20i", &n, &sign );

   double *in  = fftw_malloc( n * sizeof( double ) );
   double *out = fftw_malloc( n * sizeof( double ) );
   fftw_plan plan = fftw_plan_r2r_1d( n, in, out, FFTW_DHT, FFTW_ESTIMATE );

   for( i = 0 ; i < n ; i++ )
      scanf( "%20lf", &in[i] );

   fftw_execute( plan ); // where the magic happens

   sqrtn = sqrt( n );

   printf( "%i %i\n", n, sign );

   for( i = 0 ; i < n ; i++ )
      printf( "%.15lf\n", out[i] / sqrtn );

   fftw_destroy_plan( plan );
   fftw_free( in  );
   fftw_free( out );
}
