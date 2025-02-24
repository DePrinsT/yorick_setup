#! /bin/bash
#*******************************************************************************
# LAOG project
#
# "@(#) $Id: pack.sh,v 1.2 2010-08-20 10:07:12 ccmgr Exp $"
#
# Script to pack yoco in a single tar.gz package.
# Based on yocoPack.sh, part of the JMMC software yoco
#
# $Log: not supported by svn2svn $
# Revision 1.1  2010/05/21 15:23:41  fmillour
# add the pack.sh and yocoInstall.sh scripts to be able to distribute yoco as standalone
#
#
#*******************************************************************************


# SVN LOCATION
SVNREPOBASE="https://forge.osug.fr/svn/ipag-sw/YOCO/"

# Print usage 
function printUsage () {
    echo -e "Usage: pack [-h] [-t tag]" ;
    echo -e "\t-h\tprint this help.";
    echo -e "\t-b\tbuild a binary parckage for this machine architecture";
    echo -e "\t-t <tag>\tuse revision 'tag' when retrieving modules.\n";
    echo -e "\t        \tretrieve them from repository"
    exit 1;
}

# Parse command-line parameters
tag="";
format="src";
pkgSrc="";
while getopts "bht:" option
# Initial declaration.
# h and t are the options (flags) expected.
# The : after option 't' shows it will have an argument passed with it.
do
  case $option in
    h ) # Help option
        printUsage ;;
    b ) # Format option
        format="bin";;
    t ) # Tag option
        tag="$OPTARG";;
    * ) # Unknown option
        echo "Invalid option -- $option"
        printUsage ;;
    esac
done


# Get root directory
currDir=$PWD


# Retrieve modules from CVS repository
    echo "Retrieving yoco module..."
    modules="yoco"

    # Check modules do not exist
    for module in $modules ; do
        if test -d $module ;
        then
            echo "Please delete your current module directory '$module' first."
            exit 1
        fi
    done

    # Set log file
    logFile=$PWD/yoco-pack.log
    rm -f $logFile
    touch $logFile
    if [ $? != 0 ]
    then
        echo "ERROR - could not access log file $logFile"
        exit 1
    fi

    # Checkout modules
    if [ "$tag" != "" ]
    then
	SVNLOCATION=${SVNREPOBASE}/tags/${tag}/
	# if a tag is given, then use it
	version=$tag
    else
	SVNLOCATION=${SVNREPOBASE}/trunk/
	# if no tag given, then version name is "SVN" followed by the current date
	version="SVN"`date +%Y%m%d`
    fi

    svn export --non-interactive $SVNLOCATION/$modules > $logFile 2>&1
    if [ $? != 0 ]
    then
        echo -e "\nERROR: 'svn export --non-interactive $SVNLOCATION/$modules' failed ... \n"; 
        tail $logFile
        echo -e "See log file '$logFile' for details."
        exit 1;
    fi

    # Create directory where to put source files
    echo "Preparing yoco package (version $version) ..."
    pkgSrc=yoco-$version-src
    rm -rf $pkgSrc
    mv $modules $pkgSrc

    # Copy install script to the root 
    cp $pkgSrc/distrib/yocoInstall.sh $pkgSrc/install.sh
    chmod 755 $pkgSrc/install.sh

# Build binary package if requested
if [ "$format" == "bin" ];
then
    echo "Building yoco software..."
    # Go to the source directory
    cd $pkgSrc
    # Get kernel-name and hardware-platform
    kernel=`uname -s`
    if [ "$kernel" == "Darwin" ];
    then
        platform=`uname -p`
    else
        platform=`uname -m`
    fi

    # Set package name
    pkg=yoco-$version-bin-$kernel-$platform
    # Set INTROOT
    export INTROOT=$currDir/$pkg
    rm -rf $INTROOT
    # Add it to PATH and LD_LIBRARY_PATH
    export PATH=$INTROOT/bin:/$INTROOT/yorick/bin:$PATH
    export LD_LIBRARY_PATH=$INTROOT/lib:$LD_LIBRARY_PATH
    # Build package
    ./install.sh -y
    if [ $? != 0 ]
    then
        echo -e "\nERROR: software package compilation failed ... \n"; 
        tail $logFile
        echo -e "See log file '$logFile' for details."
        exit 1;
    fi    
    # Go back to root directory
    cd $currDir
else
    pkg=$pkgSrc
fi

# Create a .tgz file
echo "Building yoco package..."
tar -czf $pkg.tgz ./$pkg
echo "    $pkg.tgz"

echo "Cleaning yoco package..."
rm -rf ./$pkg ./$pkgSrc

echo -e "yoco package created!"

#
# ___oOo___
