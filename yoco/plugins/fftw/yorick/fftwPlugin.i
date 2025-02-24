local package_fftwPlugin;
/*******************************************************************************
 * LAOG project - Yorick Contribution package 
 * 
 * Simple wrapper of FFTW for Yorick.
 *
 * "@(#) $Id: fftwPlugin.i,v 1.5 2007-09-24 12:34:25 gzins Exp $"
 *
 * History
 * -------
 * $Log: not supported by cvs2svn $
 * Revision 1.4  2007/03/28 12:11:37  gzins
 * Used __ suffix for wrapped functions
 *
 * Revision 1.3  2007/02/16 09:28:56  gzins
 * Programming standards
 *
 * Revision 1.2  2007/02/02 07:34:31  gzins
 * Added example
 *
 * Revision 1.1  2007/02/01 07:52:20  gzins
 * *** empty log message ***
 */

if (_PRINT==1)
{
    write,"#include \"fftwPlugin.i\"";
}

func fftwPlugin(void)
/* DOCUMENT fftwPlugin(void)

  DESCRIPTION
    Simple plugin of FFTW for Yorick

  VERSION
    $Revision: 1.5 $

  REQUIRE
    Libraries -lfftw -lrfftw

  CAUTIONS

  AUTHORS
    - Jean-Baptiste LeBouquin

  FUNCTIONS
    - fftwc   : FFT of array of complex values
    - fftwr   : FFT of array of real values
*/
{
    version = strpart(strtok("$Revision: 1.5 $",":")(2),2:-2);
    if (am_subroutine())
    {
        write, format="package version: %s\n", version;
        help, fftwPlugin;
    }   
    return version;
} 

/* Check the version of Yorick */
__vers = double();
sread, strpart(Y_VERSION,1:3), format="%f", __vers;

#include "fftwPluginWrapper.i"

func fftwc(arr, &fftarr)
/* DOCUMENT fftwc(arr, &fftarr)
  
  DESCRIPTION
    Transforms a single, contiguous input array of complex values to a
    contiguous output array.
  
  PARAMETERS
    - arr    : input array
    - fftarr : output array. The format is the same as for the input array.
  
  RETURN VALUES
    Complex 1D fft of the complex 1D input array
  
  SEE ALSO:
    fftwr, fftwPlugin
 */
{
    n   = long(dimsof(arr)(2));
    arr = fftarr = complex(arr);
    __fftwComplex1D, &arr, &fftarr, n;

    return fftarr;
}

func fftwr(arr, &fftarr)
/* DOCUMENT fftwr(arr,&fftarr)
   
  DESCRIPTION
    Transforms a single, contiguous input array of real values to a contiguous
    output array.
  
  PARAMETERS
    - arr    : input array
    - fftarr : output array. The format is the same as for the input array.
  
  EXAMPLE
    #include "fftwPlugin.i"
    
    x = span(0,10,1024);
    y = sin(90*x) + random(dimsof(x)) - 0.5;
    
    ffty = fftwr(y);
    
    window,0;
    plg,y,x;
    
    window,1;
    plg,abs(ffty);
  
  RETURN VALUES
    Complex 1D fft of the real 1D input array

  SEE ALSO:
    fftwc, fftwPlugin
 */
{
    n   = long(dimsof(arr)(2));
    arr = fftarr = float(arr);
    __fftwReal1D, arr, fftarr, n;
    return fftarr;
}
 
FLAG_FFTW = 1;
  
