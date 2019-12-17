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

init (){

    if [ -f "$HOME/.config/addressbookhelper.rc" ];then
        echo "dslkfjsdf"
        readarray -t line < "$HOME/.config/addresbookhelper.rc"
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
    if [ "$1" == "" ]; then 
        szAnswer=$(zenity --timeout 30 --entry --text "What are we searching for?" --entry-text ""); echo $szAnswer
    else
        szAnswer="$1"
    fi
    echo "$ContactsDir"
    echo "lsdk"
    results=($(grep -Rl "$ContactsDir" --exclude-dir=.git -i -e "$szAnswer" ))
    
    for ((i=0; i<${#results[@]}; ++i));
    do
        
        FileName[$i]=$(echo ${results[$i]})
        ShortFileName[$i]=$(basename ${FileName[$i]})
        Identifier[$i]="${ShortFileName[$i]%.*}"
        PeopleName[$i]=$(grep ${FileName[$i]} -e "FN:" | awk -F ":" '{print $2}' | tr -d '\r')
    done
    if [ ${#results[@]} == 0 ];then
        #TODO: CATCH FOR CLI ONLY
        zenity --error --text "No matches found!"
        exit
    elif [ ${#results[@]} == 1 ];then
        i=0
    else
        #TODO: CATCH FOR CLI ONLY
        buildstring=$(printf ' FALSE "%s" ' "${PeopleName[@]}")
        choicecmdline="zenity --list --height 400 --width 250 --text 'Which to display?' --radiolist  --column 'Pick' --column 'Name' $buildstring"
        ChosenName=$(eval "$choicecmdline")
        i=0
        for a in "${PeopleName[@]}"; do
            [[ $a == "$ChosenName" ]] && { echo "$i"; break; }
            (( ++i ))
        done
    fi
    
}

##############################################################################
# VCardReader
##############################################################################
read_vcard() {
    
 
    #if display image switch
    #if has image
    #photoextractor
    
}

##############################################################################
# Display the Entry
##############################################################################
display_choice() {
    
    #CLI CATCH HERE
    #Ignores the -i switch, huh?
    
    SelectedVcard="${FileName[$i]}"
    read_vcard

    #for displaying images; need to make sure base64 there and converts it to HTML
            if [ -f "$PicFileName" ];then
            data=$(ppl show ${Identifier[$i]} | awk '{$0 = "<p>" $0 "</p>"} 1')
            (echo "$data<img src=\"data:"
            mimetype -b "$PicFileName"
            echo -n ";base64,"
            base64 "$PicFileName"
            echo "\">") | zenity --text-info --html --filename=/dev/stdin         
            rm "$PicFileName"
    
    if [ -z "$pplexe" ];then
        # This output needs to be cleaned up eventually
        cmdline="cat ${FileName[$i]} | zenity --text-info --width 400 --height 400 --title=${PeopleName[$i]} "
    else

    fi
    eval "$cmdline"
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
}

##############################################################################
# Sort out commandline options    
##############################################################################    

while [ $# -gt 0 ]; do
option="$1"
    case $option
    in
    -m) MuttStyle="true"
    CliOnly="true"
    shift ;;   
    -h) display_help
    exit
    shift ;;         
    -i) Images="false"
    shift ;;      
    esac
done    

init
choose_entry
display_choice
