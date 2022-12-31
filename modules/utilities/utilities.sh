
function utilities_banner_menu()
{
cat << "EOF"
 (`-').->(`-')  _(`-')                 _  (`-') 
 ( OO)_  ( OO).-/( OO).->       .->    \-.(OO ) 
(_)--\_)(,------./    '._  ,--.(,--.   _.'    \ 
/    _ / |  .---'|'--...__)|  | |(`-')(_...--'' 
\_..`--.(|  '--. `--.  .--'|  | |(OO )|  |_.' | 
.-._)   \|  .--'    |  |   |  | | |  \|  .___.' 
\       /|  `---.   |  |   \  '-'(_ .'|  |      
 `-----' `------'   `--'    `-----'   `--'      
EOF
    echo
    echo
cat << "EOF"
    1.) Tor Network
    2.) Clear results files
    4.) Previous Menu
EOF
    echo
    printf "%s" "Option: "
    read 

}

function clear_results_files()
{
    printf "%s" "Confirm you wish to remove all results files (Y|n) "
    read delete_results
    if (($delete_results == "Y" || $delete_results == "y")) 
    then 
        rm -R lists/results/*
        echo "results files deleted" | grep --color "results files deleted"
    fi 
}


function tor_network()
{
    if (($STILETTO_TOR eq ''))
    then 
        echo "Tor is not being used" | grep --color "Tor is not being used"
        echo
        echo "   1.) Use Tor Network"
    else 
        echo "Tor is being used" | grep --color "Tor is being used"
        echo
        echo "   1.) Stop using Tor Network"
    fi
    echo "   2.) Back to Utilities Menu"
    printf "%s" "Option: "
    read tor_result
}

function main()
{
    while [ 1 == 1 ]
    do 
        utilities_banner_menu
        if (($REPLY == "1"))
        then 
            tor_network
        elif (($REPLY == "2"))
        then 
            clear_results_files
        elif (($REPLY == "4"))
        then 
            break
        fi 
    done 
}


#-------- main ---------
clear
main
