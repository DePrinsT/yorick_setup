#!/bin/bash
#*******************************************************************************
# LAOG project
#
# "@(#) $Id: install.sh,v 1.37 2011-01-04 16:45:00 mella Exp $"
#
# Intallation script for tools/librarie commonly used with Yorick 
#
#
#*******************************************************************************

# Print usage 
function printUsage () {
echo -e "Usage: install [-h] [-y] [-l <file>] [-C <dir>] [-F <dir>]" ;
    echo -e "\t-h\tprint this help.";
    echo -e "\t-y\tassume "yes" to all questions";
    echo -e "\t-l <file>\tuse the specified 'file' for logging installation messages.";
    echo -e "\t-C <dir>\tspecify directory where cfitsio library is installed";
    echo -e "\t-F <dir>\tspecify directory where fftw2 library is installed";
    echo -e "\t (The way to use your proper fftw3 library is still missing)";
}

yesNo()
{
    if [ $# -gt 2 ];
    then
        echo "Usage : yesNo <question> [<forceYes>]"
        exit 1
    fi

    if [ $# == 2 ];
    then
        if [ "$2" == "yes" ];
        then
            return 1
        fi
    fi

    while true
    do
        echo -n "$1 (Y/N)? "
        read answer
        case $answer in
            [yYoO]*) return 1;;
            [nN]*)   return 0;;
        esac
    done 
}

# Parse command-line parameters
assumeYes="no";
logFile=""
installCFITSIO=yes
installFFTW2=no
installYorick=yes
installFFTW3=yes
installYocoPck=yes
installOiFitsUtilsPck=yes
installYocoPlugin=yes
installFftwPlugin=no
installCfitsioPlugin=yes
installCatalogs=yes
installSaft=no

# Fix #731 that polute Terminal output on MacOs El Capitan
if sw_vers &> /dev/null
then
  installSaft=yes
fi



while getopts "hyl:C:F:s" option
do
  case $option in
    h ) # Help option
        printUsage;
        exit 0;;
    y ) # Assume yes option
        assumeYes="yes";;
    l ) # Log-file option
        logFile="$OPTARG";;      
    C ) # CFITSIO installation directory
        installCFITSIO=no
        export CFITSIO_LIB_DIR="$OPTARG";;
    F ) # FFTW installation directory
        installFFTW2=no
        export FFTW_LIB_DIR="$OPTARG";;
    s ) # force installation of saft ( testing / not documented )
        installSaft=yes;;
    * ) # Unknown option
        echo "Invalid option -- $option"
        printUsage;
        exit 1;;
    esac
done

# Get root directory
currDir=$PWD

# Set log file
if [ "$logFile" == "" ] ;
then
    logFile=$PWD/install.log
    rm -f "$logFile"
fi
echo "Run YOCO - install.sh at $(date)" >> "$logFile"
if [ $? != 0 ]
then
    echo "ERROR - could not access log file $logFile"
    exit 1
fi
echo "Log file is $logFile"

# Get kernel-name and hardware-platform
kernel=`uname -s`
if [ "$kernel" == "Darwin" ];
then
    platform=`uname -p`
    nbproc=`sysctl hw.ncpu | awk '{print $2}'`
else
    platform=`uname -m`
    nbproc=`nproc`
fi

echo "Installing tools/librairies for Yorick on $kernel/$platform with $nbproc cores"
echo ""
# Verify that the ${INTROOT} is set
if test "${INTROOT}" ;
then
    echo -e "Installation directory is ${INTROOT}" ;
    for dir in "${INTROOT}" "${INTROOT}/bin" "${INTROOT}/lib" "${INTROOT}/config";
    do
        if test ! -d "${dir}" ;
        then
            echo "    Creating ${dir} ..."
            mkdir "${dir}"
        fi
    done
else
    echo -e "ERROR: INTROOT variable, defining installation directory, is not set !"
    exit ;
fi

# define one variable that will be given to configure scripts and make them work even 
# if the INTROOT contains spaces
INTROOT_FOR_CONFIGURE="${INTROOT/ /\ }"


function _unpack(){
  _package=$1
  _version=$2
  _archive=$1*$2.t*gz
  echo -e "   Unpacking ..."
  rm -rf $_package
  tar xzf $_archive >> "$logFile" 2>&1
  chmod -R +rw $_package $_package*$_version &> /dev/null
}
 

# Installation of cfitsio libary
if [ $installCFITSIO == "yes" ]
then
    cfitsioVersion=2510
    echo ""
    yesNo "Do you want to install cfitsio library" $assumeYes
    if [ $? == 1 ];
    then   
        cd "$currDir"
        echo -e "Installing cfitsio library V${cfitsioVersion}..."
        
        _unpack cfitsio $cfitsioVersion 
        
        echo -e "   Configuring ..."
        cd  cfitsio
        ./configure --prefix=${INTROOT_FOR_CONFIGURE} >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "   Building ..."
        make -j$nbproc clean all >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "   Installing ..."
        make install >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "   Cleaning ..."
        make clean >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "Done."
    fi
fi

# Installation of fftw2 library
if [ $installFFTW2 == "yes" ]
then
    fftwVersion=2.1.5
    echo ""
    yesNo "Do you want to install fftw library V${fftwVersion}" $assumeYes
    if [ $? == 1 ];
    then   
        cd "$currDir"
        echo -e "Installing fftw library V${fftwVersion} ..."
        
        _unpack fftw ${fftwVersion}
        
        echo -e "   Configuring ..."
        cd  fftw-${fftwVersion}
        ./configure --with-pic --enable-float --enable-type-prefix --prefix=${INTROOT_FOR_CONFIGURE} >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "   Building ..."
        make -j$nbproc  >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "   Installing ..."
        make install >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "   Cleaning ..."
        make clean >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "Done."
    fi
fi


# Installation of fftw3 library
if [ "$installFFTW3" == "yes" ]
then
    fftwVersion=3.2.2
    echo ""
    yesNo "Do you want to install fftw library V${fftwVersion}" $assumeYes
    if [ $? == 1 ];
    then   
        cd "$currDir"
        echo -e "Installing fftw library V${fftwVersion} ..."
        
        _unpack fftw ${fftwVersion}
        
        echo -e "   Configuring ..."
        cd  fftw-${fftwVersion}
        #./configure --with-pic --enable-float --enable-type-prefix --prefix=${INTROOT_FOR_CONFIGURE} >> "$logFile" 2>&1
        ./configure --with-pic --enable-type-prefix --prefix=${INTROOT_FOR_CONFIGURE} >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "   Building ..."
        make -j$nbproc >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "   Installing ..."
        make install >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "   Cleaning ..."
        make clean >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "Done."
    fi
fi


# Installation of rlterm tool removed and replaced by a single information message:
echo ""
echo "rlwrap or rlterm programs offer command recall and command-line editing capabilities." 
echo "Please install it using your package manager on linux or download it for MacOs X from http://jmmc.fr/~swmgr/rlwrap" 

# Next steps require a working yorick
# the ls `which cmd` has been placed to work on macos10.4 
# that always returns 0 for which execution on non existing commands
if which yorick && ls `which yorick` >/dev/null
then
    echo  ""
    echo  "Yorick is already installed in '"`which yorick`"'" 
    yesNo  "Do you want to force one new install into INTROOT" $assumeYes
    if [ $? == 0 ];
    then
	installYorick="no";
    fi
else
    echo  ""
    yesNo "Do you want to install yorick program" $assumeYes
    if [ $? == 0 ];
    then
        echo "Yorick cannot be found... installation end."
	exit 0
    fi 
fi

# Installation of yorick 
if [ "$installYorick" == "yes" ]
then
    yv=2
    ysv=2
    yssv=04
    echo -e "Installing yorick..."

    # Installation directory
    cd "$currDir"
    yHome="$INTROOT/yorick"
    echo "   Yorick installation directory is '$yHome'."
    yesNo "   Do you accept it" $assumeYes
    if [ $? == 0 ];
    then   
        echo -n "    New installation directory? :"
        read yHome
    fi
    echo -e "   Creating installation directory ..."
    mkdir -p $yHome >> "$logFile" 2>&1
    if [ $? != 0 ]
    then
        echo "Failed. Please have a look to $logFile"
        exit 1
    fi
    
    _unpack yorick $yv.$ysv.$yssv

    echo -e "   Building ..."
    cd  yorick-$yv.$ysv*/
    
    # fix popen bug on macosx >= 10.7  (http://trac.jmmc.fr/jmmc-sw/ticket/270)
    # & work arround an exp10 missing symbol during final link 
    #      ( exp10 seems detected during makefile creation but build fails )
    if sw_vers &> /dev/null
    then
	MAJOR_MAC_VERSION=$(sw_vers -productVersion | awk -F '.' '{print $1 "." $2}' | sed "s/10\.//g")
        min=`(echo "7" ; echo "$MAJOR_MAC_VERSION") | sort -n | head -1`
        if [ "$min" = "7" ]; then
  	    export CFLAGS="-D_XOPEN_SOURCE=500 -DNO_EXP10" 
            echo "Setting CFLAGS to '$CFLAGS'" >> "$logFile" 2>&1
        fi
    fi

    make -j$nbproc relocatable >> "$logFile" 2>&1
    if [ $? != 0 ]
    then
        echo "Failed. Please have a look to $logFile"
        exit 1
    fi
    echo -e "   Installing ..."
    rm -rf "$INTROOT/yorick" >> "$logFile" 2>&1
    if [ $? != 0 ]
    then
        echo "Failed. Please have a look to $logFile"
        exit 1
    fi
    # * append to $yssv because produced archive get duplicated ssv 
    tar xzvf yorick-$yv.$ysv.$yssv*.tgz -C "$INTROOT"  >> "$logFile" 2>&1
    if [ $? != 0 ]
    then
        echo "Failed. Please have a look to $logFile"
        exit 1
    fi
    mv $INTROOT/yorick-$yv.$ysv*$yssv "$INTROOT/yorick"
    echo -e "   Cleaning ..."
    make clean >> "$logFile" 2>&1
    if [ $? != 0 ]
    then
        echo "Failed. Please have a look to $logFile"
        exit 1
    fi
    cd "$currDir"
    # Add yorick in the path
    echo "NOTE : You should add $yHome/bin to your path, as shown below"
    echo "       export PATH=$yHome/bin:\$PATH"
    # Actually add it so that we can install the packages and plugins
    export PATH=$yHome/bin:$PATH
fi


# Installation of yoco packages
if [ "$installYocoPck" == "yes" ]
then
    echo ""
    yesNo "Do you want to install the yoco packages" $assumeYes
    if [ $? == 1 ];
    then   
        echo -e "Installing the yoco packages..."
        cd "$currDir"
	cd ../packages
        echo -e "   Installing ..."
        make -j$nbproc all install >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "   Cleaning ..."
        make clean >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "Done."
    fi
fi

# Installation of yoco packages
if [ "$installOiFitsUtilsPck" == "yes" ]
then
    echo ""
    yesNo "Do you want to install the oiFitsUtils and imgFitsUtils packages" $assumeYes
    if [ $? == 1 ];
    then   
        echo -e "Installing the oiFitsUtils and imgFitsUtils packages..."
        cd "$currDir"
	cd ../packages/oiFitsUtils/
        echo -e "   Installing ..."
        make -j$nbproc all install >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "   Cleaning ..."
        make clean >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "Done."
    fi
fi

# Installation of yoco plugin
if [ "$installYocoPlugin" == "yes" ]
then
    echo ""
    yesNo "Do you want to install the yoco plugin" $assumeYes
    if [ $? == 1 ];
    then   
        echo -e "Installing the yoco plugin..."
        cd "$currDir"
	cd ../plugins/yoco/src
	echo -e "   Building ..."
        make -j$nbproc all do_plugin >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
	echo -e "   Installing ..."
        make install install_plugin >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "   Cleaning ..."
        make clean clean_plugin >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "Done."
    fi
fi


# Installation of fftw plugin
if [ "$installFftwPlugin" == "yes" ]
then
    echo ""
    yesNo "Do you want to install the fftw plugin" $assumeYes
    if [ $? == 1 ];
    then   
        echo -e "Installing the fftw plugin..."
        cd "$currDir"
	cd ../plugins/fftw/src
	echo -e "   Building ..."
        make -j$nbproc all do_plugin >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
	echo -e "   Installing ..."
        make install install_plugin >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "   Cleaning ..."
        make clean clean_plugin >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "Done."
    fi
fi

# Installation of cfitsio plugin
if [ "$installCfitsioPlugin" == "yes" ]
then
    echo ""
    yesNo "Do you want to install the cfitsio plugin" $assumeYes
    if [ $? == 1 ];
    then   
        echo -e "Installing the cfitsio plugin..."
        cd "$currDir"
	cd ../plugins/cfitsio/src
	echo -e "   Building ..."
        make -j$nbproc all do_plugin >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
	echo -e "   Installing ..."
        make install install_plugin >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "   Cleaning ..."
        make clean clean_plugin >> "$logFile" 2>&1
        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "Done."
    fi
fi

# Installation of catalogs
if [ "$installCatalogs" == "yes" ]
then
    echo ""
    yesNo "Do you want to install the catalogs" $assumeYes
    if [ $? == 1 ];
    then   
        echo -e "Installing the catalogs..."
        cd "$currDir"
	if [ ! -d ${INTROOT}/catalogs ];
	then 
	    echo "   Creating ${INTROOT}/catalogs ...";
	    mkdir -p ${INTROOT}/catalogs; 
	fi; 

	echo -e "   Copying ..."
	cp -vrf ../catalogs/* $INTROOT/catalogs/  >> "$logFile" 2>&1

        if [ $? != 0 ]
        then
            echo "Failed. Please have a look to $logFile"
            exit 1
        fi
        echo -e "Done."
    fi
fi

# Installation of Stand-alone FITS tools
if [ "$installSaft" == "yes" ]
then
  echo ""
  yesNo "Do you want to install the Stand-alone FITS tools" $assumeYes
  if [ $? == 1 ];
  then
    echo -e "Installing Stand-alone FITS tools..."
    _unpack saft ""
    cd saft 
    echo -e "   Building ..."
    BINDIR=${INTROOT}/bin make >> "$logFile" 2>&1
    echo -e "Done."
    cd -
  fi
fi


# Installation done
echo -e "Installation done!"

exit 0
