#!/bin/bash

##############################################################################
# Credits, blame, etc
##############################################################################
#	pplsearch - a quick addressbook launcher (for openbox?)

#   Requires ppl https://hnrysmth.github.io/ppl/
#   Strongly helpful with vdirsyncer https://github.com/pimutils/vdirsyncer

##############################################################################
# Initialize
##############################################################################

MuttStyle="false"
Images="false"
CliOnly="false"
RefreshVCards="false"
APPDIR=$(dirname $(realpath "$0"))
source "$APPDIR/vcardreader.sh"

init (){

    if [ -f "$HOME/.config/addressbookhelper.rc" ];then
        readarray -t line < "$HOME/.config/addressbookhelper.rc"
        ContactsDir=${line[1]}
        #test line 3 first in case is empty or not true/false
        RefreshVCards=${line[3]}
    else
        ContactsDir=$PWD
    fi
}


##############################################################################
# Entry Chooser
##############################################################################

choose_entry() {
    
    
    # Using fzf and rofi here REALLY took a lot of speed and weight off 
    if [ "$CliOnly" == "true" ];then
        SelectedVcard=$(rg "FN:" /home/steven/.contacts/contacts/* | awk -F ':' '{print $3 ":" $1 }' | fzf --no-hscroll -m --height 50% --border --ansi --no-bold --header "Whose Vcard?" | awk -F ':' '{print $2}' | realpath -p )
    else
        #use ROFI, not zenity 
        SelectedVcard=$(rg "FN:" /home/steven/.contacts/contacts/* | awk -F ':' '{print $3 ":" $1 }' | rofi -i -dmenu -p "Whose Vcard?" -theme DarkBlue | awk -F ':' '{print $2}' | realpath -p)
    fi

    if [ ! -f "$SelectedVcard" ];then
        if [ "$CliOnly" == "true" ];then
            echo "No matches found!"
            exit 88
        else
            zenity --error --text "No matches found!"
            exit 88
        fi
    fi
    
}


##############################################################################
# Display the Entry
##############################################################################
display_choice() {
    
    #sourced
    result=$(read_vcard)
    
    if [ "$CliOnly" == "true" ];then
        if [ "$MuttStyle" == "true" ];then
            #need fzf and such here to find only email addresses if more than 1
            echo "$result"
        else
            # use boxes here optionally
            echo "$result"
        fi
        
    else

#TODO - below about displaying with ROFI
#TODO - Maybe get rid of config file just for convenience sake? It's only the
#contacts directory
#TODO - remove "update vcard", because you should be using a different tool for that
#TODO - remove mentions of images

            #FOR FUCKS SAKE, maybe just rip this out and figure out how to display 
        # results with rofi...rofi
        # rofi -modi yourscript:./hr -show yourscript  < - this is how
        
        
            echo "$result" | zenity --text-info --filename=/dev/stdin         
        
    fi

 
}

##############################################################################
# Show the Help
##############################################################################
display_help(){
    #no switch, just argument - string to search for
    # -h show help
    # -i use images
    # -m mutt style response (just return email, implies cli only)
    # -c cli only 
    echo "sdlfk"
}

##############################################################################
# Sort out commandline options    
##############################################################################    

while [ $# -gt 0 ]; do
option="$1"
    case $option in
    -m) MuttStyle="true"
        CliOnly="true"
        shift ;;   
    -h) display_help
        exit
        shift ;;         
    -i) Images="false"
        shift ;;      
    -c) CliOnly="true"
        shift ;;      
    esac
done    

init
choose_entry
display_choice

#fzf example for cli version
#
