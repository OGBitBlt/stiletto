#
# PROXY CHECKER MODULE FOR STILETTO 
#
# Proxy checker will check IP Addresses to see if they have an open 
# proxy server running on them, if found the script will collect geo 
# information.
# 
# Results are stored in results/shuriken
#------------------------------------------------------------------------------
# Do a quick check to make sure we were sourced by stiletto and not run as a
# stand alone bash script
if ! [ -n "$STILETTO_MODULES_DIR" ]; then 
    echo "PROXYCHECKER CAN NOT BE RUN AS A STANDALONE SCRIPT, MUST BE CALLED FROM STILETTO."
    exit
fi
#
#------------------------------------------------------------------------------
# Read IP addresses from a file 1 line at a time
function readfile() 
{
    if ! [ -f "$STILETTO_PROXY_PORT_LIST" ]; then
        echo "Unable to find port list file: $STILETTO_PROXY_PORT_LIST"
        return 
    else 
        echo "Reading $PROXYFILE using ports from $STILETTO_PROXY_PORT_LIST"
        while read line
            do addr=$line 
            while read port
                do PROXYADDRESS="$addr:$port"
                check_proxy & 
                sleep 2.5
            done < "$STILETTO_PROXY_PORT_LIST"
        done < "$PROXYFILE"
    fi 
}
#
#------------------------------------------------------------------------------
# check a single ip address to see if it has an open proxy on it
function check_proxy()
{
    echo "Searching for a SOCKS4 proxy on: $PROXYADDRESS..." | grep --color "SOCKS4"
    res5=$(curl --connect-timeout 10 -m 20 -s -x "socks4://$PROXYADDRESS" http://lumtest.com/myip.json)
    if [ "$res5" == "" ]; then  
        echo "Searching for a SOCKS5 proxy on: $PROXYADDRESS..." | grep --color "SOCKS5"
        res4=$(curl --connect-timeout 10 -m 20 -s -x "socks5://$PROXYADDRESS" http://lumtest.com/myip.json)
        if ! [ "$res4" == "" ]; 
        then 
            echo "socks4:$res4"
        fi
    else 
        echo "socks5:$res5"
    fi
}
#
#------------------------------------------------------------------------------
# Display a fancy banner
function proxy_checker_banner()
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
# Main menu for proxy checker
function proxy_checker_menu()
{
    clear
    echo 
    proxy_checker_banner
    echo
    echo 
    select proxy_checker_menu_selection in "Use results list" "Use my list (one IP per line)" "Enter an IP address" "None, exit Proxy checker"
    do
        case $proxy_checker_menu_selection in
            "Use results list")
                if [ -f "$STILETTO_SHOTGUN_PROXY_FILE" ]; then
                    PROXYFILE="$STILETTO_SHOTGUN_PROXY_FILE"
                    readfile
                    echo "Finished checking proxies, results are in $STILETTO_SHURIKEN_PROXY_FILE"
                else
                    echo "No results files found, maybe you forgot to run the scanner first?"
                fi
                break
            ;;
            "Use my list (one IP per line)")
                printf "%" "Enter File Name: " | grep --color 'Enter File Name:'
                read file_name
                if [ -f $file_name ]; then
                    PROXYFILE="$file_name"
                    readfile
                    echo "Finished checking proxies, results are in $STILETTO_SHURIKEN_PROXY_FILE"
                else
                    echo "File $file_name not found."
                fi
                break
            ;;
            "Enter an IP address")
            ;;
            "None, exit Proxy checker")
                echo "Ciao!" | grep --color "Ciao!"
                EXIT_PROXY_CHECKER=1
                break;
            ;;
        esac
    done
}
#------------------------------------------------------------------------------
#   let the magic, begin...
#------------------------------------------------------------------------------
EXIT_PROXY_CHECKER=0
while [ $EXIT_PROXY_CHECKER == 0 ]
do
    proxy_checker_menu
done 
# EOF

