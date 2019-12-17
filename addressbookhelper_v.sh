#!/bin/bash

########################################################################
# Credits, blame, etc
########################################################################
#	pplsearch - a quick addressbook launcher (for openbox?)

#   Requires ppl https://hnrysmth.github.io/ppl/
#   Strongly helpful with vdirsyncer https://github.com/pimutils/vdirsyncer

########################################################################
# Usage     
########################################################################

#   Run the thing 

########################################################################
# Requires
########################################################################

# * zenity or a replacement like matedialog or wenity.

########################################################################
# Configuration (do we use a ppl directory or the current directory?)
########################################################################
    pplexe=$(which ppl)      
    tmpdir=$(mktemp -d) 
    SelectedVcard=""
    
    if [ -f ~/.pplconfig ];then
        PPLDIR=$(sed -n '/[addressbook]/{n;p;}' ~/.pplconfig | awk -F "= " '{print $2}')
    else
        PPLDIR=$PWD
    fi

########################################################################
#vcf_photo_extractor ver 20180207094631 Copyright 2018 alexx, MIT Licence
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


    if [ "$1" == "" ]; then 
        szAnswer=$(zenity --timeout 30 --entry --text "What are we searching for?" --entry-text ""); echo $szAnswer
    else
        szAnswer="$1"
    fi

    results=($(grep -Rl "$PPLDIR" --exclude-dir=.git -i -e "$szAnswer" ))
    
    for ((i=0; i<${#results[@]}; ++i));
    do
        
        FileName[$i]=$(echo ${results[$i]})
        ShortFileName[$i]=$(basename ${FileName[$i]})
        Identifier[$i]="${ShortFileName[$i]%.*}"
        PeopleName[$i]=$(grep ${FileName[$i]} -e "FN:" | awk -F ":" '{print $2}' | tr -d '\r')
    done
    if [ ${#results[@]} == 0 ];then
        zenity --error --text "No matches found!"
        exit
    elif [ ${#results[@]} == 1 ];then
        i=0
    else
        buildstring=$(printf ' FALSE "%s" ' "${PeopleName[@]}")
        choicecmdline="zenity --list --height 400 --width 250 --text 'Which to display?' --radiolist  --column 'Pick' --column 'Name' $buildstring"
        ChosenName=$(eval "$choicecmdline")
        i=0
        for a in "${PeopleName[@]}"; do
            [[ $a == "$ChosenName" ]] && { echo "$i"; break; }
            (( ++i ))
        done
    fi
    
    SelectedVcard="${FileName[$i]}"
    photoextractor
    if [ -z "$pplexe" ];then
        # This output needs to be cleaned up eventually
        cmdline="cat ${FileName[$i]} | zenity --text-info --width 400 --height 400 --title=${PeopleName[$i]} "
        eval "$cmdline"
    else
        if [ -f "$PicFileName" ];then
            data=$(ppl show ${Identifier[$i]} | awk '{$0 = "<p>" $0 "</p>"} 1')
            (echo "$data<img src=\"data:"
            mimetype -b "$PicFileName"
            echo -n ";base64,"
            base64 "$PicFileName"
            echo "\">") | zenity --text-info --html --filename=/dev/stdin         
            rm "$PicFileName"
        else
            cmdline="ppl show ${Identifier[$i]} | zenity --text-info --width 400 --height 400 --title=${PeopleName[$i]} "
            eval "$cmdline"
        fi
    fi
    
    
    

    
