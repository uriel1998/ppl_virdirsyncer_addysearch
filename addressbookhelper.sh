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

########################################################################
# vcf_photo_extractor ver 20180207094631 Copyright 2018 alexx, MIT Licence
# https://stackoverflow.com/a/48660570
########################################################################
photoextractor(){
    
    DATA=$(cat "$SelectedVcard" |tr -d "\r\n"|sed -e 's/.*TYPE=//' -e 's/END:VCARD.*//')
    NAME=$(grep -a '^N;' $SelectedVcard|sed -e 's/.*://')
    #if [ $(wc -c <<< $DATA) -lt 5 ];then #bashism
    if [ $(echo $DATA|wc -c) -lt 5 ];then
      echo "No images found in $SelectedVcard"
      return 2
    fi
    EXT=$(echo "${DATA%%:*}" | awk -F ';' '{print $SelectedVcard}' )
    if [ "$EXT" == 'BEGIN' ]; then echo "FAILED to extract $EXT"; return 3; fi
    IMG=${DATA#*:}
    FILE=${SelectedVcard%.*}
    Fn=${FILE##*/}
    PicFileName="$tempdir/${FILE}.${EXT}"
    echo $IMG | base64 -id > "$PicFileName"

    if [ -f "$PicFileName" ];then
        convert "$PicFileName" -resize 200x200\> "$PicFileName"
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

    #for displaying images; need to make sure base64 there and converts it to HTML
            if [ -f "$PicFileName" ];then
            data=$(ppl show ${Identifier[$i]} | awk '{$0 = "<p>" $0 "</p>"} 1')
            (echo "$data<img src=\"data:"
            mimetype -b "$PicFileName"
            echo -n ";base64,"
            base64 "$PicFileName"
            echo "\">") | zenity --text-info --html --filename=/dev/stdin         
            rm "$PicFileName"
            fi
        # This output needs to be cleaned up eventually
#        cmdline="cat ${FileName[$i]} | zenity --text-info --width 400 --height 400 --title=${PeopleName[$i]} "
        echo "$result"
 
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
