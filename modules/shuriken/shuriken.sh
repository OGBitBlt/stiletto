#
# SHURIKEN MODULE FOR STILETTO 
#
# The shuriken module is for focused attacks on targets. Shuriken functions
# all start with a results list, or a list provided by the user of targets 
# that have been "qualified" typically by using the shotgun scanning methods.
# 
# Shuriken will validate the target vulnerability, and attempt to penetrate
# the found vulnerability.... whatever that may be.
#
# Results are stored in results/shuriken
#------------------------------------------------------------------------------
# Do a quick check to make sure we were sourced by stiletto and not run as a
# stand alone bash script
if ! [ -n "$STILETTO_MODULES_DIR" ]; then 
    echo "SHURIKEN CAN NOT BE RUN AS A STANDALONE SCRIPT, MUST BE CALLED FROM STILETTO."
    exit
fi
#------------------------------------------------------------------------------
#   GLOBALS
#------------------------------------------------------------------------------
STILETTO_RDP_CHECKER="$STILETTO_SHURIKEN_DIR/rdp/rdp_checker.sh"
STILETTO_RDP_CRACKER="$STILETTO_SHURIKEN_DIR/rdp/rdp_cracker.sh"
STILETTO_PROXY_CHECKER="$STILETTO_SHURIKEN_DIR/proxy/proxy_checker.sh"
STILETTO_SQLI_CHECKER="$STILETTO_SHURIKEN_DIR/sqli/sqli_checker.sh"
STILETTO_LFI_CHECKER="$STILETTO_SHURIKEN_DIR/lfi/lfi_checker.sh"
STILETTO_RFI_CHECKER="$STILETTO_SHURIKEN_DIR/rfi/rfi_checker.sh"
STILETTO_SHURIKEN_RDP_CRACKED="$STILETTO_SHURIKEN_RESULT_DIR/rdp_cracked.lst"
STILETTO_SHURIKEN_SQLI_FILE="$STILETTO_SHURIKEN_RESULT_DIR/sql_injection.lst"
STILETTO_SHURIKEN_RFI_FILE="$STILETTO_SHURIKEN_RESULT_DIR/remote_file_injection.lst"
STILETTO_SHURIKEN_LFI_FILE="$STILETTO_SHURIKEN_RESULT_DIR/local_file_injection.lst"
#
#------------------------------------------------------------------------------
# Display a fancy banner
function shuriken_banner()
{
echo
cat << "EOF"
                 /\
                /  \
                |  |
              __/()\__
             /   /\   \
            /___/  \___\
EOF
}
#
#------------------------------------------------------------------------------
# Main menu functionality for shuriken
function shuriken_menu()
{
    clear 
    echo
    shuriken_banner
    echo 
    echo 
    echo "Shuriken is for targeted attacks. It does not hunt, instead it uses "
    echo "targets that have already been discoverd using Shotgun."
    echo "You can also supply your own list of targets for Shuriken to attack"
    echo "The file must contain 1 target per line."
    echo 
    echo "In bocca al lupo!" | grep --color "In bocca al lupo!"
    echo 
    select shuriken_menu_selection in "Proxy Checker" "Remote Desktop Checker" "Remote Desktop Cracker" "SQL Injection" "Local File Injection" "Remote File Injection" "None, Exit Shuriken"
    do
        case $shuriken_menu_selection in 
            "Proxy Checker")
                source $STILETTO_PROXY_CHECKER
                echo "Finished checking proxies, results are stored in $STILETTO_SHURIKEN_PROXY_FILE"
                break
            ;;
            "Remote Desktop Checker")
                source $STILETTO_RDP_CHECKER
                echo "Finished checking RDPs, results are stored in $STILETTO_SHURIKEN_RDP_FILE"
                break
            ;;
            "Remote Desktop Cracker")
                source $STILETTO_RDP_CRACKER
                echo "Finished cracking RDPs, results are stored in $STILETTO_SHURIKEN_RDP_CRACKED"
                break
            ;;
            "SQL Injection")
                source $STILETTO_SQLI_CHECKER
                echo "Finished checking SQL injection, results are stored in $STILETTO_SHURIKEN_SQLI_FILE"
                break
            ;;
            "Local File Injection")
                source $STILETTO_LFI_CHECKER
                echo "Finished checking local file injection, results are stored in $STILETTO_SHURIKEN_LFI_FILE"
                break 
            ;;
            "Remote File Injection")
                source $STILETTO_RFI_CHECKER
                echo "Finished checking remote file injection, results are stored in $STILETTO_SHURIKEN_RFI_FILE"
                break
            ;;
            "None, Exit Shuriken")
                echo "Ciao!" | grep --color "Ciao!"
                EXIT_SHURIKEN=1
                break;
            ;;
            *)
                echo "I ciechi possono vedere meglio di te"
            ;;
        esac
    done  
}
#------------------------------------------------------------------------------
#   Let the magic, begin...
#------------------------------------------------------------------------------
EXIT_SHURIKEN=0
while [ $EXIT_SHURIKEN == 0 ]; do
    shuriken_menu
done 
# EOF
