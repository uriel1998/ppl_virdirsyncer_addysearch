#!/bin/bash

##############################################################################
# Credits, blame, etc
##############################################################################
#   pplsearch - a quick addressbook viewer for GUI, TUI, and Mutt
#   by Steven Saus 24 July 2020
#   Licenced under the MIT License
##############################################################################

##############################################################################
# Initialize
##############################################################################
SCRIPTDIR="$( cd "$(dirname "$0")" ; pwd -P )"
ContactsDir="/home/steven/.contacts/nextcloud/contacts"
MuttStyle="false"
CliOnly="false"
APPDIR=$(dirname $(realpath "$0"))
source "$APPDIR/vcardreader.sh"
RealPathSub=""
Query=""
# My individual vcf files are in this directory

##############################################################################
# Entry Chooser
##############################################################################

choose_entry() {
    echo "${Query}"
    # Using fzf and rofi here REALLY took a lot of speed and weight off 
    if [ "$CliOnly" == "true" ];then
        SelectedVcard=$(rg "FN:" /home/steven/.contacts/nextcloud/contacts/* | awk -F ':' '{print $3 ":" $1 }' | fzf -q "${Query}" --no-hscroll -m --height 50% --border --ansi --no-bold --header "Whose Vcard?" --preview="$SCRIPTDIR/vcardreader.sh {}"  | awk -F ':' '{print $2}' )
    else
        SelectedVcard=$(rg "FN:" /home/steven/.contacts/nextcloud/contacts/* | awk -F ':' '{print $3 ":" $1 }' | rofi -i -dmenu -p "Whose Vcard?" | awk -F ':' '{print $2}' )
    fi
    # Added to avoid the realpath -p switch
    SelectedVcard=$(realpath "${SelectedVcard}")
    
    
    
    
    if [ ! -f "$SelectedVcard" ];then
        if [ "$CliOnly" == "true" ];then
            echo "No matches found!"
            exit 88
        else
            rofi -e "No matches found!"
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
            num_emails=$(echo -e "$result" | rg -c -e "✉" )
            if [[ "$num_emails" -gt 1 ]];then
                echo "$result" | rg -e "✉" | fzf --no-hscroll -m --height 50% --border --ansi --no-bold --header "Which email address?" | awk -F ': ' '{print $2}'
            else
                echo "$result" | rg -e "✉" | awk -F ': ' '{print $2 }'
            fi 
        else
            echo "$result" | tee >(xclip -i -selection primary) >(xclip -i -selection secondary) >(xclip -i -selection clipboard)
        fi       
    else
        echo "$result" | tee >(xclip -i -selection primary) >(xclip -i -selection secondary) >(xclip -i -selection clipboard) >(rofi -e "$result")
    fi

 
}

##############################################################################
# Show the Help
##############################################################################
display_help(){
    echo "###################################################################"
    echo "#  pplsearch.sh [-h|-m|-c]"
    echo "# -h show help "
    echo "# -m mutt style response (just return email, implies cli only) "
    echo "# -c cli/tui interface only "
    echo "###################################################################"
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
    -c) CliOnly="true"
        shift ;;      
    *) Query="${Query} ${1}"
        shift 
        ;;
    esac
done    


choose_entry "${Query}"
display_choice

#fzf example for cli version
#
