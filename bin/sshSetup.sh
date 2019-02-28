#!/bin/sh
# add -xv above to debug.

#################################################################
#					    SSH Setup Script
# Remarks
#	 1.		None 
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
        echo "Usage:"
        echo " $(basename $0) [-d | -h | -q] [serverIP]"
        echo "  This script setups dsa ssh for a user and"
        echo "  establishes  an ssh connection to a server"
        echo "  if a server ip is present."
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
    local   fDoBuild=
    local   fDoClean=
    local   fDoFetch=
    local   fDoInstall=
    local   fDoPatch=

    # Parse off the command arguments.
    if [ $# = 0 ]; then             # Handle no arguments given.
        fDoBuild=y
        fDoClean=y
        fDoFetch=y
        fDoInstall=y
        fDoPatch=y
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
                -f) 
                    fDoFetch=y
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
    fi
        
	# Check to see if ssh security is already installed.
    if [ -f "${HOME}/.ssh/id_dsa" ]; then
		echo "WARNING - ssh security already seems to be set up for this user!"
		getReplyYN "Do you want to redo it?" y
		if test $? -eq 0
		then
            rm -fr "${HOME}/.ssh"
		fi
	fi

	# Setup the SSH Security if needed.
    if [ -f "${HOME}/.ssh/id_dsa" ]; then
        :
    else
        echo	"Setting up .SSH directory for DSA..."
        ssh-keygen -t dsa -b 1024
        if [ -n "${spclDir}" ] && [ -d "${spclDir}" ]; then
            if [ -d "${spclDir}/spcl/${USER}/ssh" ]; then
                :
            else
                mkdir -p "${spclDir}/spcl/${USER}/ssh"
            fi
            cp -v  "${HOME}/.ssh/id_dsa"        "${spclDir}/spcl/${USER}/ssh/"
            cp -v  "${HOME}/.ssh/id_dsa.pub"    "${spclDir}/spcl/${USER}/ssh/"
        fi
    fi
    
    # Authorize us on a server if it was supplied.
    if [ -n "$1" ]; then
        setupIP $1
    fi
    
    return $?
}


#-----------------------------------------------------------------
#						Setup SSH on an IP
#-----------------------------------------------------------------

setupIP( ) {

	# Do initialization.
	DEST_IP=$1
	echo	"Setting up SSH connection to ${DEST_IP}..."
	
	# See if we are already authorized on that computer.
	if [ -f "${HOME}/.ssh/known_hosts" ]; then
	    if cat "${HOME}/.ssh/known_hosts" | grep "${DEST_IP}" 2>&1 >/dev/null
	    then
    		echo "WARNING - an ssh connection may already be set up for ${DEST_IP}!"
    		getReplyYN "Do you want to set it up anyway?" y
    		if test $? -ne 0
    		then
    		    return 4
    		fi
	    fi
	fi

	#  Get us authorized on the server.
    if [ -f "${HOME}/.ssh/id_dsa.pub" ]; then
        echo	"Setting up SSH connection to ${DEST_IP}..."
        echo    "Enter your password whenever it is requested:"
        ssh ${USER}@${DEST_IP} 		"mkdir -p	~/.ssh; chmod 755	~/.ssh"
#		ssh ${USER}@${DEST_IP} 		"chmod 755	~/.ssh"
        scp "${HOME}/.ssh/id_dsa.pub" 	    ${USER}@${DEST_IP}:~/.ssh/new_computer_dsa
        ssh ${USER}@${DEST_IP} 		"cat ~/.ssh/new_computer_dsa >> ~/.ssh/authorized_keys; chmod 600	~/.ssh/authorized_keys; rm  ~/.ssh/new_computer_dsa"
#		ssh ${USER}@${DEST_IP} 		"chmod 600	~/.ssh/authorized_keys"
#		ssh ${USER}@${DEST_IP} 		"rm  ~/.ssh/new_computer_dsa"
    else
        echo "ERROR - Missing ~/.ssh/id_dsa.pub"
        exit 8
    fi

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



