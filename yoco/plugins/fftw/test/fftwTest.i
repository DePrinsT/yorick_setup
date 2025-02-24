/* 
 * Check the Wrapper of FFTW for Yorick.
 *   - fftwr, fftwc...
 *
 * Author : LeBouquin, jblebou@obs.ujf-grenoble.fr
 *
 * $Log: not supported by cvs2svn $
 * Revision 1.1  2007/02/01 07:52:43  gzins
 * *** empty log message ***
 *
 */

#include "fftwPlugin.i"

x = span(0,10,1024);
y = (float)(sin(90*x) + random(dimsof(x)) - 0.5);

ffty = fftwr(y);

window,0;
plg,y,x;

window,1;
plg,abs(ffty);

pause,1000;
quit;
