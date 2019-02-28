#!/bin/bash -xv
# add -xv above to debug.


# Script:	Keep backup copies of the shared data up to date.
# Args:		None
# Remarks:
#	1)		This script is very customized for my installation.  I will try
#			to change that as I go through time.  (haha)


#----------------------------------------------------------------
#                       Global Variables
#----------------------------------------------------------------

    fDebug=
    fQuiet=
    lclDir="/x"
    srcDir="x:$lclDir"
    dateTime="$(date +%G%m%d)_$(date +%H%M%S)";


#################################################################
#                       Functions
#################################################################


#----------------------------------------------------------------
#                     Display the Usage Help
#----------------------------------------------------------------

displayUsage( ) {
    if test -z "$fQuiet"; then
        echo "Usage:"
        echo " $(basename $0) [-d | -h | -q | -s path] [path to ${lclDir}]*"
        echo "  This script updates certain direcotories from the base"
        echo "  using RSync. If a path is provided, it is used and"
        echo "  a search of the computer is not performed."
        echo
        echo "Flags:"
        echo "  -d, --debug     Debug Mode"
        echo "  -h, --help      This message"
        echo "  -q, --quiet     Quiet Mode"
        echo "  -s, --src       Provides path to '${lclDir}' source. Defaults to: ${srcDir}"
    fi
    exit 4
}


#----------------------------------------------------------------
#                     Get the Date and Time
#----------------------------------------------------------------

getDateTime () { 
    DateTime="$(date +%G%m%d)_$(date +%H%M%S)";
    return 0
}



#-----------------------------------------------------------------
#						Main Process
#-----------------------------------------------------------------

main( ) {

    # Parse off the command arguments.
    if [ $# = 0 ]; then             # Handle no arguments given.
        :
    else
        # Parse off the flags.
        while [ $# != 0 ]; do
            flag="$1"
            case "$flag" in
                -d | --debug) 
                    fDebug=y
                    if test -z "$fQuiet"; then
                        echo "In Debug Mode"
                    fi
                    set -xv
                    ;;
                -h | --help) 
                    displayUsage
                    return 4
                    ;;
                -q) 
                    fQuiet=y
                    ;;
                -s | --src) 
                    shift
                    if test -z "$1"; then
                        echo "FATAL: Missing source path to '$lclDir'!"
                        displayUsage
                        return 4
                    fi
                    srcDir=$1
                    if test -z "$fQuiet"; then
                        echo "Changed source directory to '$srcDir'."
                    fi
                    ;;
                -*)
                    if test -z "$fQuiet"; then
                        echo "FATAL: Found invalid flag: $flag"
                    fi
                    displayUsage
                    ;;
                *)
                    break                       # Leave while loop.
                    ;;
            esac
            shift
        done
    fi
        
    # Set up the Source of files to be copied.
    if [ "xyzzy" = "${HOSTNAME}" ]; then
        echo "FATAL - Not set up to run on applex01!"
        return 4
    fi
    
    # Now try destinations on the current computer.
    errorLogPath="${HOME}/rsync.errorlog.${dateTime}.txt"
    if [ $# = 0 ]; then             # Handle no arguments given.
        case $OSTYPE in
       	cygwin )					# *** Win32-Cygwin ***
            if [ -d "/cygdrive/e/common06/common01$lclDir" ]; then
                rsyncDir "$srcDir" "/cygdrive/e/common06/common01$lclDir"
            fi
            if [ -d "/cygdrive/e/common08/common01${lclDir}" ]; then
                rsyncDir "$srcDir" "/cygdrive/e/common08/common01${lclDir}"
            fi
           	;;
       	darwin* )					# *** MacOSX ***
            if [ -d "/Volumes" ]; then
				# NOTE -- this is not working when wrkDir contains spaces.  Need
				#         fix if possible.
                for wrkDir in $(ls -1 /Volumes); do
                    # Use only locally mounted volumes.
                    if diskutil list | grep "${wrkDir}" 2>&1 1>/dev/null
                    then
                        if [ -d "/Volumes/${wrkDir}${lclDir}" ]; then
                            if rsyncDir "$srcDir" "/Volumes/${wrkDir}${lclDir}" 2>"${errorLogPath}"
                            then
                                rm "${errorLogPath}"
                            fi
                        fi
                    fi
                done
            fi
    		;;
       	linux-gnu )					# *** Linux ***
            if [ -d "/mnt" ]; then
                # Use only locally mounted volumes.   <<<<<<<< Add this check!!!!!!
                for wrkDir in $(ls -1 /Volumes); do
                    if [ -d "/mnt/${wrkDir}${lclDir}" ]; then
                        if rsyncDir "$srcDir" "/mnt/${wrkDir}${lclDir}" 2>"${errorLogPath}"
                        then
                            rm "${errorLogPath}"
                        fi
                    fi
                done
            fi
    		;;	
       	msys )						# *** Win32-MinGW ***
    		;;	
       	* )							# *** Everything Else ***
    		echo "...Invalid OSTYPE of $OSTYPE!"
    		exit 1	
    		;;
        esac
    else
        # Parse off the flags.
        while [ $# != 0 ]; do
            rsyncDir "$srcDir" "${1}"
            shift
        done
    fi

    return 0
}


#----------------------------------------------------------------
#   Update the specified Directory from the base using RSync
#----------------------------------------------------------------

rsyncDir () {

#	Get the input variables.
	dirSrc="$1"
	dirDst="$2"
    if test -n "$fDebug"; then
        echo "...rsyncDir($1,$2)"
    fi
	sleep 60					# add time for launchctl

	if [ -d "$dirDst" ];
	then
        echo ">>>rsync -avz --delete-after ${dirSrc}  ${dirDst}/"
        if rsync -av --compress --delete-after --exclude '.*' "${dirSrc}"  "${dirDst}/"
        then
            :
        else
            echo "ERROR - rsync to ${dirDst} failed!"
            exit 4
        fi
	fi

}



#################################################################
#                       Main Function
#################################################################

    # Do initialization.
	getDateTime
	TimeStart="${DateTime}"

    # Scan off options and verify.
    
    # Perform the main processing.
	main  $@
	mainReturn=$?

	getDateTime
	TimeEnd="${DateTime}"
    if test -z "$fQuiet"; then
        if [ 0 -eq $mainReturn ]; then
            echo		   "Successful completion..."
        else
            echo		   "Unsuccessful completion of ${mainReturn}"
        fi
        echo			"   Started: ${TimeStart}"
        echo			"   Ended:   ${TimeEnd}"
	fi

	exit	$mainReturn

