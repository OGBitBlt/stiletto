#
# PROXY SCANNER MODULE FOR STILETTO 
#
# The proxy scanner automates scanning a network for open proxy ports
# 
# The results of the scanning are stored in the proxy_found.lst file and stored
# in the shotgun results folder.
#
#------------------------------------------------------------------------------
# Do a quick check to make sure we were sourced by stiletto and not run as a
# stand alone bash script
if ! [ -n "$STILETTO_MODULES_DIR" ]; then 
    echo "SHOTGUN CAN NOT BE RUN AS A STANDALONE SCRIPT, MUST BE CALLED FROM STILETTO."
    exit
fi
#
#------------------------------------------------------------------------------
# creates an empty results file, displays a warning if one already exists
function check_proxy_results_file()
{
    if [ -f $STILETTO_SHOTGUN_PROXY_FILE ]; then 
        $STILETTO_EXISTING_PROXY_FILE=1
    else 
        echo "# The folling IP Addresses have a proxy port open" > $STILETTO_SHOTGUN_PROXY_FILE
    fi 
}
#
#------------------------------------------------------------------------------
# Displays a fancy banner 
function proxy_scanner_banner()
{
cat << "EOF"
    ___    ___     ___   __  __  __   __ 
   | _ \  | _ \   / _ \  \ \/ /  \ \ / / 
   |  _/  |   /  | (_) |  >  <    \ V /  
  _|_|_   |_|_\   \___/  /_/\_\   _|_|_  
_| """ |_|"""""|_|"""""|_|"""""|_| """ | 
"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-' 
EOF
}
#
#------------------------------------------------------------------------------
# Read IP Ranges from a file 1 line at a time
function readfile() 
{
    printf "reading %s\n" $IPRANGEFILE
    while read line; do
        IPRANGE=$line
        scaniprange 
    done < $IPRANGEFILE
}
#
#------------------------------------------------------------------------------
# Call NMAP on the specified IP Range, checking each target for ports open.
# Ports are specified in the lists/ports/rdp_ports.list file.
# is open. When we find one, append it to the results file. 
function scaniprange() 
{
    echo "Scanning IP Range : $IPRANGE" | grep --color "Scanning IP Range :"
    nmap -p8080,8181,8081,1080,8123,3128,9050,9051 -P0 -oG - -sS $IPRANGE | sed -n 's/.* \([0-9\.]\{7,\}\).*\/open\/.*/\1/p' >> $STILETTO_SHOTGUN_PROXY_FILE
}
#
#------------------------------------------------------------------------------
# Main module menu
function proxy_scanner_main_menu()
{
    clear 
    echo 
    proxy_scanner_banner
    echo 
    echo 
    echo "Proxy Scanner."
    echo "Scan a range of IP addresses to see if they are running a proxy service, "
    echo "determine if the port is open, and if so save it to a log file."
    echo "You can perform deeper pentests on this log file from the Shuriken menu, seleting the "
    echo "option to use a results file."
    echo 
    echo "The next step is to detemine what IP range to scan in our testing"
    echo "Selection an option to continue: " | grep --color 'Selection an option to continue:'
    select proxy_scanner_option in "Use a stored list" "Use my own list (one ip range per line)" "Enter an IP Range" "None, exit Proxy Scanner" 
    do
        case $proxy_scanner_option in
              "Use a stored list") 
                    printf "%s" "List Name: " | grep --color 'List Name:'
                    read list_name_input
                    IPRANGEFILE="$STILETTO_IPRANGE_DIR/$list_name_input.lst"
                    if [ -f "$IPRANGEFILE" ]; then 
                        readfile
                        echo "Finished scanning list. Results are in $STILETTO_SHOTGUN_PROXY_FILE" | grep --color "Finished scanning list."
                        echo "Press enter to continue..." | grep --color 'Press enter to continue...'
                        read 
                    fi
                    unset list_name_input
                    unset REPLY 
                break;
              ;;
              "Use my own list (one ip range per line)")
                    printf "%s" "File Location: " | grep --color 'File Location:'
                    read file_location_input
                    IPRANGEFILE="$file_location_input"
                    if [ -f "$IPRANGEFILE" ]; then 
                        readfile
                        echo "Finished scanning file. Results are in $STILETTO_SHOTGUN_PROXY_FILE" | grep --color "Finished scanning file."
                        echo "Press enter to continue..." | grep --color 'Press enter to continue...'
                        read 
                    fi
                    unset file_location_input 
                    unset REPLY
                break;
              ;;
              "Enter an IP Range")
                    printf "%s" "IP Range to Scan: " | grep --color 'IP Range to Scan:'
                    read ip_range_input 
                    IPRANGE="$ip_range_input"
                    scaniprange
                    echo "Finished scanning IP range. Results are in $STILETTO_SHOTGUN_PROXY_FILE" | grep --color "Finished scanning IP range."
                    echo "Press enter to continue..." | grep --color 'Press enter to continue...'
                    read 
                    unset ip_range_input
                    unset REPLY
                break;
              ;;
              "None, exit Proxy Scanner")
                EXIT_PROXYSCANNER=1
                break;
              ;;
              *)
                echo "Come on stupid, pay attention!" | grep --color 'Come on stupid, pay attention!'
              ;;
        esac 
    done
}
#------------------------------------------------------------------------------
#   Let the magic, begin...
#------------------------------------------------------------------------------
check_proxy_results_file
EXIT_PROXYSCANNER=0
while [ $EXIT_PROXYSCANNER == 0 ]
do 
    proxy_scanner_main_menu
done
# EOF