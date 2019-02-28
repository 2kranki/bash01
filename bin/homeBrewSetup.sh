#!/bin/bash
# add -xv above to debug.
# vi:nu:et:sts=4 ts=4 sw=4

#################################################################
#			        Setup Home Brew	
# Remarks
#	 1.		Instead of patching makefiles, we override the 
#           necessary parameters from the command line to make
#           the installation succeed.
#    2.     This will probably work in 10.3 as well, but it has
#           not been tested.
#################################################################

#----------------------------------------------------------------
#                       Global Variables
#----------------------------------------------------------------

    fDebug=
    fQuiet=
    szScriptDir=
    szScriptName=
    szScriptPath=

    HB_PATH1="/usr/local/Cellar"




#################################################################
#                       Functions
#################################################################

#----------------------------------------------------------------
#                   Download and Install Homebrew
#----------------------------------------------------------------

downloadAndInstallHomebrew () {

    if test -z "$fQuiet"; then
        echo "Downloading and installing Homebrew..."
    fi

    if ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" ; then
        echo "...Successfully downloaded and installed Homebrew"
    fi

    # Insure that it is ok.
    if brew doctor ; then
        echo "...Everything is installed correctly"
    fi

    if launchctl setenv PATH \"/usr/local/bin:$PATH\" ; then
        echo "...Adjusted to use Homebrew"
    fi

    return $?
}


#----------------------------------------------------------------
#                       Install Apache
#----------------------------------------------------------------

installApache () {

    if test -z "$fQuiet"; then
        echo "Downloading and installing Apache..."
    fi

    brew update

    if brew tap homebrew/dupes ; then
        echo "...Everything is installed correctly"
    fi

    if brew tap homebrew/versions ; then
        echo "...Everything is installed correctly"
    fi

    if brew tap homebrew/homebrew-php ; then
        echo "...Everything is installed correctly"
    fi

    if brew install php56 ; then
        echo "...Everything is installed correctly"
    fi

    return $?
}


#----------------------------------------------------------------
#                       Install LLVM
#----------------------------------------------------------------

installLLVM () {

    if test -z "$fQuiet"; then
        echo "Downloading and installing LLVM..."
    fi

    brew update

    if brew tap homebrew/dupes ; then
        echo "...Everything is installed correctly"
    fi

    if brew tap homebrew/versions ; then
        echo "...Everything is installed correctly"
    fi

    if brew install llvm ; then
        echo "...Everything is installed correctly"
    fi

    return $?
}


#----------------------------------------------------------------
#                       Install MacVim
#----------------------------------------------------------------

installMacVim () {

    if test -z "$fQuiet"; then
        echo "Downloading and installing MacVim..."
    fi

    brew update

    if brew tap homebrew/dupes ; then
        echo "...Everything is installed correctly"
    fi

    if brew tap homebrew/versions ; then
        echo "...Everything is installed correctly"
    fi

    if brew tap homebrew/homebrew-php ; then
        echo "...Everything is installed correctly"
    fi

    if brew install MacVim ; then
        echo "...Everything is installed correctly"
    fi

    return $?
}


#----------------------------------------------------------------
#                       Install PHP 5.6
#----------------------------------------------------------------

installPHP56 () {

    if test -z "$fQuiet"; then
        echo "Downloading and installing PHP 5.6..."
    fi

    brew update

    if brew tap homebrew/dupes ; then
        echo "...Everything is installed correctly"
    fi

    if brew tap homebrew/versions ; then
        echo "...Everything is installed correctly"
    fi

    if brew tap homebrew/homebrew-php ; then
        echo "...Everything is installed correctly"
    fi

    if brew install php56 ; then
        echo "...Everything is installed correctly"
    fi

    return $?
}


#----------------------------------------------------------------
#                       Install QuickLook Generators
#----------------------------------------------------------------

installQL () {

    if test -z "$fQuiet"; then
        echo "Downloading and installing Quicklook Generators..."
    fi

    brew update

    if brew tap homebrew/dupes ; then
        echo "...Everything is installed correctly"
    fi

    if brew tap homebrew/versions ; then
        echo "...Everything is installed correctly"
    fi

    if brew tap homebrew/homebrew-php ; then
        echo "...Everything is installed correctly"
    fi

    if brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json ; then
        echo "...Everything is installed correctly"
    fi

    if brew cask install qlprettypatch quicklook-csv betterzipql ; then
        echo "...Everything is installed correctly"
    fi

    if brew cask install qlimagesize webpquicklook suspicious-package ; then
        echo "...Everything is installed correctly"
    fi

    return $?
}


#----------------------------------------------------------------
#                       Update Homebrew
#----------------------------------------------------------------

hbUpdate () {

    if test -z "$fQuiet"; then
        echo "Updating Homebrew..."
    fi

    if brew tap homebrew/dupes ; then
        echo "...Everything is installed correctly"
    fi

    if brew tap homebrew/versions ; then
        echo "...Everything is installed correctly"
    fi

    if brew tap homebrew/homebrew-php ; then
        echo "...Everything is installed correctly"
    fi

    return $?
}


#----------------------------------------------------------------
#                     Display the Usage Help
#----------------------------------------------------------------

displayUsage( ) {
    if test -z "$fQuiet"; then
        setColors
        setColors BACK_WHITE
        echo "Usage:"
        echo " $(basename $0) [-d | -h | --ip newIP | -q] ( commands - see below )"
        echo "  This script installs homebrew, macvim or php56 depending on options"
        echo "  entered. The 'install' option should come first before the others."
        echo
        echo "Commands:"
        echo "  install         Install Homebrew"
        echo "  apache          Use Homebrew to install Apache"
        echo "  llvm            Use Homebrew to install LLVM"
        echo "  macvim          Use Homebrew to install MacVim"
        echo "  php56           Use Homebrew to install PHP v5.6"
        echo "  ql              Use Homebrew to install Quicklook Generators"
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
    local   fForce=
    local   fMacVim=
    local   fPHP56=

    if [ "robert" == "${USER}" ]; then
        :
    else
        echo "ERROR - Must be run by robert, not ${USER}!"
        return 8
    fi

    # Parse off the command arguments.
    if [ $# -eq 0 ]; then             # Handle no arguments given.
        if test -z "$fQuiet"; then
            echo "FATAL: Found no options "
        fi
        displayUsage
        return 4
    else
        # Parse off the flags.
        while [ $# -gt 0 ]; do
            flag="$1"
            case "$flag" in
                -d | --debug) 
                    fDebug=y
                    if test -z "$fQuiet"; then
                        echo "In Debug Mode"
                    fi
                    ;;
                 -f | --force) 
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

        # Handle the fixed arguments.
        echo "Looking at fixed arguments..."
        while [ $# != 0 ]; do
            opt="$1"
            case "$opt" in
                apache) 
                    installApache
                    ;;
                install) 
                    downloadAndInstallHomebrew
                    ;;
                macvim) 
                    installMacVim
                    ;;
                php56) 
                    installPHP56
                    ;;
                ql) 
                    installQL
                    ;;
                update) 
                    hbUpdate
                    ;;
                *)
                    if test -z "$fQuiet"; then
                        echo "FATAL: Found invalid option: $opt"
                    fi
                    displayUsage
                    ;;
            esac
            shift
        done
    fi

    return $?
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
	setColors

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

