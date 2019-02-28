#!/bin/bash
# add -xv above to debug.

# vi:nu:et:sts=4 ts=4 sw=4

#################################################################
#		    MD5 Utility
# Remarks
#	 1.		???
#################################################################

#----------------------------------------------------------------
#                       Global Variables
#----------------------------------------------------------------

    fDebug=
    fQuiet=
    szScriptDir=
    szScriptName=
    szScriptPath=


#################################################################
#                       Functions
#################################################################

#----------------------------------------------------------------
#                     Display the Usage Help
#----------------------------------------------------------------

displayUsage( ) {
    if test -z "$fQuiet"; then
        setColors
        setColors BACK_WHITE
        echo "Usage:"
		echo " $(basename $0) [-d | -h | -q] ( c | create | chk | check ) (file or directory path(s))*"
        echo "  This script checks and creates md5 check files for"
        echo "  given file or directory paths."
        echo
        echo "Flags:"
        echo "  -d, --debug     Debug Mode"
        echo "  -h, --help      This message"
        echo "  -q, --quiet     Quiet Mode"
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
#							getReplyYN
#-----------------------------------------------------------------
getReplyYN( ) {

	szMsg="$1"
	if [ -z "$2" ]; then
		szDefault="y"
	else
		szDefault="$2"
	fi
	
	while [ 0 ]; do
        if [ "y" = "${szDefault}" ]; then
            szYN="Yn"
        else
            szYN="Ny"
        fi
        echo "${szMsg} ${szYN}<enter> or q<enter> to quit:"
        read ANS
        if [ "q" = "${ANS}" ]; then
            exit 8
        fi
        if [ "" = "${ANS}" ]; then
            ANS="${szDefault}"
        fi
        if [ "y" = "${ANS}" ] || [ "Y" = "${ANS}" ]; then
            return 0
        fi
        if [ "n" = "${ANS}" ]  || [ "N" = "${ANS}" ]; then
            return 1
        fi
        echo "ERROR - invalid response, please enter y | n | q."
    done
}


#----------------------------------------------------------------
#                     Do Main Processing
#----------------------------------------------------------------

main( ) {
    local   fDoReset=
    local   fDoSet=

    # Parse off the command arguments.
    if [ $# -eq 0 ]; then             # Handle no arguments given.
        if test -z "$fQuiet"; then
            echo "FATAL: missing command"
        fi
    fi

    # Parse off the flags.
    while [ $# -gt 0 ]; do
        flag="$1"
        if test -n "$fDebug"; then
            echo "debug - looking at flag, $flag"
        fi
        case "$flag" in
            -d | --debug) 
                fDebug=y
                if test -z "$fQuiet"; then
                    echo "In Debug Mode"
                fi
                ;;
            -f) 
                fForce=y
                ;;
            -h | --help)
                displayUsage
                return 4
                ;;
            -q) 
                fQuiet=y
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
    if test -n "$fDebug"; then
        echo "debug - last flag looked at was $flag"
    fi

    # perform the command.
    if [ $# != 0 ]; then
        opt="$1"
        if test -n "$fDebug"; then
            echo "debug - looking at command, $opt"
        fi
        case "$opt" in
            c | create)
                shift
                if [ $# -gt 0 ]; then
                    :
                else
                    if test -z "$fQuiet"; then
                        echo "ERROR - Missing the file path(s)!"
                    fi
                    exit 8
                fi
                while [ $# -gt 0 ]; do
                    md5create "$1"
                    shift
                done
                ;;
            chk | check)
                shift
                if [ $# -gt 0 ]; then
                    :
                else
                    if test -z "$fQuiet"; then
                        echo "ERROR - Missing the file path(s)!"
                    fi
                    exit 8
                fi
                while [ $# -gt 0 ]; do
                    if test -n "$fDebug"; then
                        echo "debug - parms = $*"
                        echo "debug - parm[2] = $2"
                    fi
                    md5check "$1"
                    shift
                done
                ;;
            co | copy)
                shift
                if [ $# -gt 0 ]; then
                    :
                else
                    if test -z "$fQuiet"; then
                        echo "ERROR - Missing the file path(s)!"
                    fi
                    exit 8
                fi
                while [ $# -gt 0 ]; do
                    md5copy "$1"
                    shift
                done
                [ $# -eq 0 ]
                ;;
            *)
                if test -z "$fQuiet"; then
                    echo "FATAL: Found invalid command: $opt"
                fi
                displayUsage
                ;;
        esac
        shift
    fi

    return 0
}


#----------------------------------------------------------------
#           Check the MD5 File for a File or Directory
#----------------------------------------------------------------

md5check () {

    if [ $# -gt 0 ]; then
        :
    else
        if test -z "$fQuiet"; then
            echo "ERROR - Missing the file path for md5 checking!"
        fi
        exit 8
    fi
    if test -n "$fDebug"; then
        echo "debug - md5check \"$1\""
    fi

    start_dir="${1}"
    md5_file="${start_dir}.md5"
    if test -z "$fQuiet"; then
        echo "...checking ${md5_file}"
    fi

    if [ -f "${md5_file}" ]; then
        :
    else
        md5_file="${start_dir}.md5.txt"
        if [ -f "${md5_file}" ]; then
            :
        else
            if test -z "$fQuiet"; then
                echo "ERROR - ${md5_file} does not exist!"
            fi
        fi
    fi
    
    if [ -d "${start_dir}" ]; then
        start_dir=`echo "${1}" | sed -e "s/\/*$//" `
        md5_file="${start_dir}.md5"
        if tar c "${start_dir}" | md5 | cmp --verbose - "${md5_file}"; then
            :
        else
            if test -z "$fQuiet"; then
                echo "FATAL - ${md5_file} did not validate!"
            fi
            exit 8
            if getReplyYN "Do you want to still use it?"; then
                :
            else
                echo "Quitting..."
                exit 8
            fi
        fi
    elif [ -f "${start_dir}" ]; then
        if md5 <"${start_dir}" | cmp --verbose - "${md5_file}"; then
            :
        else
            if test -z "$fQuiet"; then
                echo "FATAL - ${md5_file} did not validate!"
            fi
            exit 8
            if getReplyYN "Do you want to continue?"; then
                :
            else
                echo "Quitting..."
                exit 8
            fi
        fi
    else
        if test -z "$fQuiet"; then
            echo "ERROR - ${start_dir} is neither a file or a directory!"
        fi
        exit 8
    fi

    return 0
}



#----------------------------------------------------------------
#           Copy a File or Directory with md5 verification
#----------------------------------------------------------------

md5copy () {

    if [ $# -gt 1 ]; then
        :
    else
        if test -z "$fQuiet"; then
            echo "ERROR - Missing the file path for md5 checking!"
        fi
        exit 8
    fi

    echo "NOT DEBUGGED!!!"

    start_dir="${1}"
    md5_file="${start_dir}.md5"
    if test -z "$fQuiet"; then
        echo "...checking ${md5_file}"
    fi

    if [ -f "${md5_file}" ]; then
        :
    else
        if test -z "$fQuiet"; then
            echo "ERROR - ${md5_file} does not exist!"
        fi
    fi
    
    if [ -d "${start_dir}" ]; then
        start_dir=`echo "${1}" | sed -e "s/\/*$//" `
        md5_file="${start_dir}.md5"
        if tar c "${start_dir}" | md5 | cmp --verbose - "${md5_file}"; then
            :
        else
            if test -z "$fQuiet"; then
                echo "FATAL - ${md5_file} did not validate!"
            fi
            exit 8
            if getReplyYN "Do you want to still use it?"; then
                :
            else
                echo "Quitting..."
                exit 8
            fi
        fi
    elif [ -f "${start_dir}" ]; then
        if md5 <"${start_dir}" | cmp --verbose - "${md5_file}"; then
            :
        else
            if test -z "$fQuiet"; then
                echo "FATAL - ${md5_file} did not validate!"
            fi
            exit 8
            if getReplyYN "Do you want to continue?"; then
                :
            else
                echo "Quitting..."
                exit 8
            fi
        fi
    else
        if test -z "$fQuiet"; then
            echo "ERROR - ${start_dir} is neither a file or a directory!"
        fi
        exit 8
    fi

    return 0
}



#----------------------------------------------------------------
#           Create the MD5 File for a File or Directory
#----------------------------------------------------------------

md5create () {

    if [ $# -gt 0 ]; then
        :
    else
        if test -z "$fQuiet"; then
            echo "ERROR - Missing the file path for md5 creation!"
        fi
        exit 8
    fi

    start_dir="${1}"
    md5_file="${start_dir}.md5"
    if [ -f "${md5_file}" ]; then
        rm "${md5_file}"
    fi
    md5_file="${start_dir}.md5.txt"
    if [ -f "${md5_file}" ]; then
        rm "${md5_file}"
    fi

    if test -z "$fQuiet"; then
        echo "...creating ${md5_file}"
    fi
    
    if [ -d "${start_dir}" ]; then
        start_dir=`echo "${1}" | sed -e "s/\/*$//" `
        md5_file="${start_dir}.md5"
        if test -n "$fDebug"; then
            echo "\tprocessing directory..."
        fi
        if tar c "${start_dir}" | md5 >"${md5_file}"; then
            :
        else
            if test -z "$fQuiet"; then
                echo "FATAL - could not create ${md5_file}!"
            fi
            exit 8
            if getReplyYN "Do you want to still use it?"; then
                :
            else
                echo "Quitting..."
                exit 8
            fi
        fi
    elif [ -f "${start_dir}" ]; then
        if test -n "$fDebug"; then
            echo "\tprocessing file..."
        fi
        if md5 <"${start_dir}" >"${md5_file}"; then
            :
        else
            if test -z "$fQuiet"; then
                echo "FATAL - could not create ${md5_file}!"
            fi
            exit 8
            if getReplyYN "Do you want to continue?"; then
                :
            else
                echo "Quitting..."
                exit 8
            fi
        fi
    else
        if test -z "$fQuiet"; then
            echo "ERROR - ${start_dir} is neither a file or a directory!"
        fi
        exit 8
    fi

    return 0
}



#----------------------------------------------------------------
#                     Set up ANSI colors for display
#----------------------------------------------------------------

setColors( ) {
    ESC=$(printf "\e")
    CHR_CANCEL="0"
    CHR_BOLD="1"
    CHR_NORMAL="2"
    CHR_UNDERLINE="4"
    CHR_BLINK="5"
    CHR_REVERSE="7"
    CHR_CONCEAL="8"
    BACK_BLACK="40"
    BACK_RED="41"
    BACK_GREEN="42"
    BACK_YELLOW="43"
    BACK_BLUE="44"
    BACK_MAGENTA="45"
    BACK_CYAN="46"
    BACK_WHITE="47"
    FORE_BLACK="30"
    FORE_RED="31"
    FORE_GREEN="32"
    FORE_YELLOW="33"
    FORE_BLUE="34"
    FORE_MAGENTA="35"
    FORE_CYAN="36"
    FORE_WHITE="37"
    if [ -z "$1" ]; then
        bckgnd=47
    elif [ "n" == "$1" ]; then
        NORMAL=
        BOLD=
        BLACK=
        RED=
        GREEN=
        YELLOW=
        BLUE=
        MAGENTA=
        CYAN=
        WHITE=
    else
        bckgnd="$1"
    fi
    CANCEL="${ESC}[${CHR_CANCEL}m"
	BOLD='${ESC}[1m'
	BLACK="${ESC}[30;${bckgnd}m"
	RED="${ESC}[${CHR_BOLD};${FORE_RED}m"
	GREEN="${ESC}[32;${bckgnd}m"
	YELLOW="${ESC}[33;${bckgnd}m"
	BLUE="${ESC}[34;${bckgnd}m"
	MAGENTA="${ESC}[35;${bckgnd}m"
	CYAN="${ESC}[36;${bckgnd}m"
	WHITE="${ESC}[37;${bckgnd}m"
}



 
#################################################################
#                       Main Function
#################################################################

    # Do initialization.
    szScriptPath="$0"
    szScriptDir=$(dirname "$0")
    szScriptName=$(basename "$0")
	getDateTime
	TimeStart="${DateTime}"
	#setColors

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
            echo		   "${RED}Unsuccessful completion of ${mainReturn}${CANCEL}"
        fi
        echo			"   Started: ${TimeStart}"
        echo			"   Ended:   ${TimeEnd}"
	fi

	exit	$mainReturn

