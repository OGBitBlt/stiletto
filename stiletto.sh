#!/bin/bash
#
# This is a collection of tools written in bash and python that have been
# useful to me while penetration testing.
# I have wrapped them in an easy to use menu driven interface and called it
# stiletto so that others, performing common pentesting practices, can take 
# advantage of automating every day tasks as part of their pentesting roles.
#
# Using these scripts for anything other then authorized penetration testing
# is not encouraged by the author in any manner. Doing so is illegal and the
# author takes absolutely no responsibilities for whatever results may come 
# to the user from doing so. 
#
# Tested on MacOS 12.6 (Monterey) & Linux Ubuntu 22.06...
#                                           ... and no gurantees there ;-)
#
# Feel free to submit changes or add to enhance the scripts at 
# http://github.com/ogbitblt/stiletto
#
# There is no license, feel free to use, re-use, modify at your own will.
#
# Feedback: ogbitblt at pm dot me
#
# In Bocca Al Lupo - O.G. BitBlt 
# 
#------------------------------------------------------------------------------
#   GLOBAL VARIABLES
#------------------------------------------------------------------------------
STILETTO_LISTS_DIR=lists
STILETTO_MODULES_DIR=modules
STILETTO_VAR_DIR=var
STILETTO_IPRANGE_DIR="$STILETTO_LISTS_DIR/ipranges"
STILETTO_PORTLIST_DIR="$STILETTO_LISTS_DIR/ports"
STILETTO_RDP_PORT_LIST="$STILETTO_PORTLIST_DIR/rdp_ports.lst"
STILETTO_PROXY_PORT_LIST="$STILETTO_PORTLIST_DIR/proxy_ports.lst"
STILETTO_RESULTS_DIR="$STILETTO_LISTS_DIR/results"
STILETTO_SHOTGUN_DIR="$STILETTO_MODULES_DIR/shotgun"
STILETTO_SHURIKEN_DIR="$STILETTO_MODULES_DIR/shuriken"
STILETTO_UTILITIES_DIR="$STILETTO_MODULES_DIR/utilities"
STILETTO_CONFIG_DIR="$STILETTO_VAR_DIR/config"
STILETTO_TEMP_DIR="$STILETTO_VAR_DIR/tmp"
STILETTO_SHOTGUN_RESULTS_DIR="$STILETTO_RESULTS_DIR/shotgun"
STILETTO_SHOTGUN_PROXY_FILE="$STILETTO_SHOTGUN_RESULTS_DIR/proxy_found.lst"
STILETTO_SHOTGUN_RDP_FILE="$STILETTO_SHOTGUN_RESULTS_DIR/rdp_found.lst"
STILETTO_SHURIKEN_RESULTS_DIR="$STILETTO_RESULTS_DIR/shuriken"
STILETTO_SHURIKEN_PROXY_FILE="$STILETTO_SHURIKEN_RESULTS_DIR/proxy_checked.lst"
STILETTO_SHURIKEN_RDP_FILE="$STILETTO_SHURIKEN_RESULT_DIR/rdp_checked.lst"

#------------------------------------------------------------------------------
#   GLOBAL FUNCTIONS
#------------------------------------------------------------------------------
#
#------------------------------------------------------------------------------
# Captures the user doing a CTRL+C allowing cleanup if necessary
trap bashtrap INT 
function bashtrap()
{
    echo
    echo 
    echo 'CTRL+C has been detected!...shutting down now' | grep --color '...shutting down now'
    exit 0
}
#
#------------------------------------------------------------------------------
# Checks that any dependant software is installed such as curl, python, nmap...
TRAPPER=0
function check_required()
{
    if ! [ -x  "$(command -v nmap)" ]; then 
        echo "[ERROR] missing nmap" | grep  --color -E "[ERROR]" 
        TRAPPER=1
    fi 
    if ! [ -x "$(command -v curl)" ]; then 
        echo "[ERROR] missing curl" | grep --color -E "[ERROR]"
        TRAPPER=1
    fi 
}
#
#------------------------------------------------------------------------------
# Checks the install and required folders, creates any storage ones.
# Exits if we are missing required modules or folders.
function check_folders()
{
    # if these folders don't exist we have an install problem
    if ! [ -d "$STILETTO_MODULES_DIR" ]; then 
        echo "[INSTALLATION ERROR]: STILETTO WAS NOT CORRECTLY INSTALLED, MISSING MODULES DIRECTORY!" | grep --color '[INSTALLATION ERROR]:' 
        exit 0
    fi 

    if ! [ -d "$STILETTO_SHOTGUN_DIR" ]; then 
        echo "[INSTALLATION ERROR]: MISSING SHOTGUN MODULE!" | grep --color '[INSTALLATION ERROR]:'
        exit 0
    fi 

    if ! [ -d "$STILETTO_SHURIKEN_DIR" ]; then 
        echo "[INSTALLATION ERROR]: MISSING SHURIKEN MODULE!" | grep --color '[INSTALLATION ERROR]:'
        exit 0
    fi 

    if ! [ -d "$STILETTO_UTILITIES_DIR" ]; then 
        echo "[INSTALLATION ERROR]: MISSING UTILITIES MODULE!" | grep --color '[INSTALLATION ERROR]:'
        exit 0
    fi 
    # if these folders don't exist we can create them
    if ! [ -d "$STILETTO_VAR_DIR" ]; then 
        mkdir $STILETTO_VAR_DIR
    fi 
    if ! [ -d "$STILETTO_CONFIG_DIR" ]; then 
        mkdir $STILETTO_CONFIG_DIR
    fi
    if ! [ -d "$STILETTO_TEMP_DIR" ]; then 
        mkdir $STILETTO_TEMP_DIR
    fi 
}
#
#------------------------------------------------------------------------------
# Display a fancy baner
function stiletto_banner()
{
cat << "EOF"
   ▄████████     ███      ▄█   ▄█          ▄████████     ███         ███      ▄██████▄  
  ███    ███ ▀█████████▄ ███  ███         ███    ███ ▀█████████▄ ▀█████████▄ ███    ███ 
  ███    █▀     ▀███▀▀██ ███▌ ███         ███    █▀     ▀███▀▀██    ▀███▀▀██ ███    ███ 
  ███            ███   ▀ ███▌ ███        ▄███▄▄▄         ███   ▀     ███   ▀ ███    ███ 
▀███████████     ███     ███▌ ███       ▀▀███▀▀▀         ███         ███     ███    ███ 
         ███     ███     ███  ███         ███    █▄      ███         ███     ███    ███ 
   ▄█    ███     ███     ███  ███▌    ▄   ███    ███     ███         ███     ███    ███ 
 ▄████████▀     ▄████▀   █▀   █████▄▄██   ██████████    ▄████▀      ▄████▀    ▀██████▀  
                              ▀                                                         
EOF
    echo "Author: O.G. BitBlt   <ogbitblt@pm.me>" | grep --color -E 'Author: O.G. BitBlt   <ogbitblt@pm.me>'
    echo
    echo "DO NOT USE THIS UTILITY ON ANY NETWORKS THAT YOU DO NOT HAVE PERMISSION TO USE"
    echo "IT ON. THE AUTHOR TAKES NO RESPONSIBLITY FOR MISUSE OF THIS UTILITY."
}
#
# -----------------------------------------------------------------------------
# This is  the main menu functionality for Stiletto. 
# Each module, once it completes, will exit back to this menu allowing the 
# user to continue their pentesting using a different module.
function module_launcher(){
    clear
    echo
    stiletto_banner
    echo 
    echo 
    echo "Select a mode to continue: " | grep  --color -E 'Select a mode to continue:'
    select stiletto_module in "SHOTGUN (WIDE SPREAD BLASTING)" "SHURIKEN (FOCUSED AIM)" "UTILITIES" "QUIT"
    do
        case $stiletto_module in
            "SHOTGUN (WIDE SPREAD BLASTING)")
                source "$STILETTO_SHOTGUN_DIR/shotgun.sh"
                break
            ;;
            "SHURIKEN (FOCUSED AIM)")
                source "$STILETTO_SHURIKEN_DIR/shuriken.sh"
                break
            ;;
            "UTILITIES")
                source "$STILETTO_UTILITIES_DIR/utilities.sh"
                break
            ;;
            "QUIT")
                echo "Goodbye!" | grep --color "Goodbye!"
                EXIT_STILETTO=1
                exit
            ;;
            *)
                echo "What are you stupid? There aren't many options!" | grep --color -E "stupid"
            ;; 
        esac
    done 
}

#------------------------------------------------------------------------------
#   let the magic, begin...
#------------------------------------------------------------------------------

check_required
if (( $TRAPPER==1 )) 
then  
    echo "please install the required software to continue."
    exit 
fi 

check_folders

EXIT_STILETTO=0
while [ $EXIT_STILETTO==0 ]
do
    module_launcher
done 
# EOF

