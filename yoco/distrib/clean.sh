#!/bin/bash
#*******************************************************************************
# LAOG project
#
# "@(#) $Id: clean.sh,v 1.5 2010-05-21 11:02:35 lebouquj Exp $"
#
# Cleaning script for tools/librarie commonly used with Yorick 
#
# $Log: not supported by cvs2svn $
# Revision 1.4  2010/04/07 08:52:02  jblebou
# Add the clean of the yoco plugin
#
# Revision 1.3  2010/01/29 13:03:20  mella
# Integrate fftw3 library installation
#
# Revision 1.2  2007/07/24 11:34:31  fmillour
# Added plugons cleaning
#
#
#*******************************************************************************

# Get root directory
currDir=$PWD

# Remove directories
echo "Cleanup"
echo "    Removing directories of installed software ..."
rm -rf cfitsio/ fftw-2.1.5/ fftw-3.2.2/ readline-5.0/ rlterm/ yorick-2.1/
rm -f install.log 
echo "    Compressing software pakage..."

# Check if there is uncompressed tar file
ls *.tar >> /dev/null  2>&1
if [ $? == 0 ];
then

    for f in *.tar; do
        gzip $f 
    done
fi

# Clean plugins
echo "    Cleaning yorick plugins..."
cd $currDir/../plugins/cfitsio/src/
make clean clean_plugin clean_all
cd $currDir/../plugins/fftw/src/
make clean clean_plugin clean_all
cd $currDir/../plugins/yoco/src/
make clean clean_plugin clean_all

# Clean packages
echo "    Cleaning yorick packages..."
cd $currDir/../packages
make clean
cd $currDir/../packages/oiFitsUtils
make clean

echo Done.
