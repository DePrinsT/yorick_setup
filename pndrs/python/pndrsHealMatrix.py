#! /usr/bin/env python

import astropy.io.fits as pyfits;
import numpy as np;
import argparse, os;

HMQ = 'HIERARCH ESO QC ';

parser = argparse.ArgumentParser ();
parser.add_argument ('filenames',type=str,nargs='+',help='Files to heal');

args = parser.parse_args ();

for filein in args.filenames:
	print ('');
	print ('Attempt to heal '+filein);
	
	hdulist = pyfits.open (filein);
	hdr = hdulist[0].header;
	
	# Loop on beams
	for b in np.arange(4):
	    if hdr[HMQ+'KAPPARAW%i AVG'%(b+1)] > 1.0: 
	        print ('Beam %i is OK'%(b+1));
	        continue;
	    print ('Heal beam %i'%(b+1));
	
	    mat = hdulist['PNDRS_MATRIX'].data[b,:,:];
	
	    ids = np.sum (mat, axis=1) != 0.0;
	    mat[ids,:,] = 1.0;
	
	# Remove the bad quality flag
	hdr[HMQ+'QUALITY FLAG'] = False;
	
	fileout= 'HEALED_'+filein;
	print ('Write to '+fileout);
	if os.path.exists (fileout): os.remove (fileout);
	hdulist.writeto (fileout);
	
	hdulist.close();


