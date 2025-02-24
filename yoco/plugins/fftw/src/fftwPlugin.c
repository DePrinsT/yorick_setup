/*******************************************************************************
 *
 * "@(#) $Id: fftwPlugin.c,v 1.2 2007-02-21 18:53:59 gzins Exp $"
 *
 * Author : Jean-Baptiste LeBouquin, jblebou@obs.ujf-grenoble.fr
 *
 * History
 * -------
 * $Log: not supported by cvs2svn $
 * Revision 1.1  2007/02/01 07:53:36  gzins
 * *** empty log message ***
 *
 *----------------------------------------------------------------------------*/

/**
 * @file
 * C-file required for FFTW wrapper for yorick
 */

/*
 * System header
 */
#include <math.h>
#include <srfftw.h>
#include <sfftw.h>

/*
 * Local header
 */
#include "fftwPlugin.h"

/**
 * Transforms a single, contiguous input array of complex values to a contiguous
 * output array. 
 *
 * @param in input array 
 * @param out  output array. The format is the same as for the input array.
 * @param n is the size of the transform. It can be  any positive integer.
 */
void fftwComplex1D(complex *in, complex *fftarr, int n)
{
    fftw_plan cp;
    
    cp = fftw_create_plan(n, FFTW_BACKWARD, FFTW_ESTIMATE | FFTW_USE_WISDOM);
    fftw_one(cp, in, fftarr);
    fftw_destroy_plan(cp);
}

/**
 * Transforms a single, contiguous input array of float values to a contiguous
 * output array. 
 *
 * @param in input array 
 * @param out  output array. The format is the same as for the input array.
 * @param n is the size of the transform. It can be  any positive integer.
 */
void fftwReal1D(float *arr_d, float *fftarr_d, int n)
{
    rfftw_plan rp;
    rp = rfftw_create_plan(n, FFTW_REAL_TO_COMPLEX,
                           FFTW_ESTIMATE | FFTW_USE_WISDOM);
    rfftw_one(rp, arr_d, fftarr_d);
    rfftw_destroy_plan(rp);
}
  
