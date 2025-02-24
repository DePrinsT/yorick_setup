#!/bin/bash
#*******************************************************************************
# LAOG project
#*******************************************************************************

# Print usage 
function printUsage () {
echo -e "Usage: install [-h] [-y] [-l <file>]" ;
    echo -e "\t-h\tprint this help.";
    echo -e "\t-y\tassume "yes" to all questions";
    echo -e "\t-l <file>\tuse the specified 'file' for logging installation messages.";
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
installPndrsPck="yes"

while getopts "hyl:C:F:" option
do
  case $option in
    h ) # Help option
        printUsage;
        exit 0;;
    y ) # Assume yes option
        assumeYes="yes";;
    l ) # Log-file option
        logFile="$OPTARG";;      
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
touch "$logFile"
if [ $? != 0 ]
then
    echo "ERROR - could not access log file $logFile"
    exit 1
fi

# Get kernel-name and hardware-platform
kernel=`uname -s`

echo "Installing pndrs, the DRS for the PIONIER instrument"
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

# Next steps require a working yorick
# the ls `which cmd` has been placed to work on macos10.4 
# that always returns 0 for which execution on non existing commands
if which yorick && ls `which yorick` >/dev/null
then
    echo  ""
    echo  "Yorick is installed in '"`which yorick`"'" 
else
    echo "Yorick cannot be found... installation end."
    exit 0
fi

# Installation of pndrs packages
if [ "$installPndrsPck" == "yes" ]
then
    echo ""
    yesNo "Do you want to install the pndrs packages" $assumeYes
    if [ $? == 1 ];
    then   
        cd "$currDir"
	cd ../src
        echo -e "   Installing ..."
        make all install >> "$logFile" 2>&1
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

# Installation done
echo -e "Installation done!"

exit 0
