#
# SHOTGUN MODULE FOR STILETTO 
#
# The shotgun module automates a shotgun approach to gathering mass amounts of
# targets for penetration testing such as scanning targets for open ports 
# that run specific penetratable services. 
#
# The shotgun module does not perfom any attempts at penetrating any targets,
# it only collects target information to perform attempted penetration on 
# in future tests.
#
#
#------------------------------------------------------------------------------
# Do a quick check to make sure we were sourced by stiletto and not run as a
# stand alone bash script
if ! [ -n "$STILETTO_MODULES_DIR" ]; then 
    echo "SHOTGUN CAN NOT BE RUN AS A STANDALONE SCRIPT, MUST BE CALLED FROM STILETTO."
    exit
fi
#------------------------------------------------------------------------------
#   GLOBALS
#------------------------------------------------------------------------------
STILETTO_RDP_SCANNER="$STILETTO_SHOTGUN_DIR/rdpscanner/rdpscanner.sh"
STILETTO_PROXY_SCANNER="$STILETTO_SHOTGUN_DIR/proxyscanner/proxyscanner.sh"
STILETTO_DORK_SCANNER="$STILETTO_SHOTGUN_DIR/dorkscanner/dorkscanner.sh"
#
#------------------------------------------------------------------------------
# Check for missing module files
function check_shotgun_files(){
    TRAPPER=0
    if ! [ -f "$STILETTO_RDP_SCANNER" ]; then 
        echo "[INSTALLATION ERROR]: STILETTO WAS NOT CORRECTLY INSTALLED, MISSING RDP SCANNER!"
        TRAPPER=1
    fi 
    if ! [ -f "$STILETTO_PROXY_SCANNER" ]; then 
        echo "[INSTALLATION ERROR]: STILETTO WAS NOT CORRECTLY INSTALLED, MISSING PROXY SCANNER!"
        TRAPPER=1
    fi 
    if ! [ -f "$STILETTO_DORK_SCANNER" ]; then 
        echo "[INSTALLATION ERROR]: STILETTO WAS NOT CORRECTLY INSTALLED, MISSING DORK SCANNER!"
        TRAPPER=1
    fi 
    if [ $TRAPPER == 1 ]; then
        echo 'press enter to exit' 
        read 
        exit 
    fi 
    # create the results directory if it isn't there
    if ! [ -d $STILETTO_SHOTGUN_RESULTS_DIR ]; then 
        mkdir $STILETTO_SHOTGUN_RESULTS_DIR
    fi 
}
#
#------------------------------------------------------------------------------
# Display a fancy banner
function shotgun_banner(){
cat << "EOF"
        ,______________________________________       
        |_________________,----------._ [____]  ""-,__  __....-----=====
                    (_(||||||||||||)___________/   ""                |
                        `----------'        [ ))"-,                   |
                                            ""    `,  _,--....___    |
                                                    `/           """"
EOF
}
#
#------------------------------------------------------------------------------
# main menu functionality 
function shotgun_main_menu(){
    clear
    echo
    shotgun_banner
    echo 
    echo 
    echo "Shotgun mode, wide blasts and hoping we hit something."
    echo "All of the results found will be stored in results files."
    echo "Perform furthur actions on those by selecting to use results files "
    echo "from the menu options in Shuriken mode."
    echo 
    echo "In bocca al lupo!"
    if ! [ -n $STILETTO_SHOTGUN_ERROR ]; then 
        echo 
        echo "*** ERROR ***: $STILETTO_SHOTGUN_ERROR" | grep --color -E '*** ERROR ***:'
        echo
    fi 
    echo 
    echo "To begin, what are we hunting for?: " | grep --color 'To begin, what are we hunting for?: '
    select shotgun_mode in "Remote Desktop Connections" "Proxy Servers" "Dork Scanning" "Nothing, exit shutgun"
    do
        case $shotgun_mode in 
            "Remote Desktop Connections")
                source $STILETTO_RDP_SCANNER
                break
            ;;
            "Proxy Servers")
                source $STILETTO_PROXY_SCANNER
                break
            ;;
            "Dork Scanning")
                source $STILETTO_DORK_SCANNER
                break;
            ;;
            "Nothing, exit shutgun")
                echo "Peace out!" | grep --color -E 'Peace out!'
                EXIT_SHOTGUN=1
                break
            ;;
            *)
                echo "What are you stupid? There aren't many options!" | grep --color -E 'stupid'
            ;;
        esac
    done 
}

#
#-------------------------------------------------------------------------------
#   let the magic, begin.
#
check_shotgun_files

EXIT_SHOTGUN=0
while [ $EXIT_SHOTGUN == 0 ]
do 
    shotgun_main_menu
done 
# EOF