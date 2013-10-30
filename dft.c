#include <math.h>
#include <fftw3.h>
#include <stdlib.h>

int main() {

   int n, i, sign;
   double sqrtn;

   scanf( "%20i", &n    );
   scanf( "%20i", &sign );

   fftw_complex *in  = fftw_malloc( n * sizeof( fftw_complex ) );
   fftw_complex *out = fftw_malloc( n * sizeof( fftw_complex ) );
   fftw_plan plan = fftw_plan_dft_1d( n, in, out, sign, FFTW_ESTIMATE );

   for( i = 0 ; i < n ; i++ ) {
      scanf( "%20lf", &in[i][0] );
      in[i][1] = 0;
   }

   fftw_execute( plan ); // where the magic happens

   sign *= -1;
   sqrtn = sqrt( n );

   printf( "%i\n%i\n", n, sign );

   for( i = 0 ; i < n ; i++ ) {

      double re  = out[i][0] / sqrtn;
      double im  = out[i][1] / sqrtn;
      double mod = sqrt( re * re + im * im );
      double arg = atan( im / re );

      printf( "%.15lf %.15lf %.15lf %.15lf %.15lf\n",
               re, im, mod, arg, 180 * M_1_PI * arg );
   }

   fftw_destroy_plan( plan );
   fftw_free( in  );
   fftw_free( out );
}
