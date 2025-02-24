#ifndef fftwPlugin_H
#define fftwPlugin_H
/*******************************************************************************
 *
 * "@(#) $Id: fftwPlugin.h,v 1.2 2007-03-09 08:23:51 gzins Exp $"
 *
 * Author : Jean-Baptiste LeBouquin, jblebou@obs.ujf-grenoble.fr
 *
 * History
 * -------
 * $Log: not supported by cvs2svn $
 * Revision 1.1  2007/02/01 07:54:04  gzins
 * *** empty log message ***
 *
 ******************************************************************************/

/**
 * @file
 * Header file for Yorick plugin of fftw library.
 */
#define complex fftw_complex

void fftwComplex1D(complex *in, complex *out, int n);
void fftwReal1D(float *in, float *out, int n);

#endif /*!fftwPlugin_H*/

/*___oOo___*/
