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
    
    if [ -f ~/.pplconfig ];then
        PPLDIR=$(sed -n '/[addressbook]/{n;p;}' ~/.pplconfig | awk -F "= " '{print $2}')
    else
        PPLDIR=$PWD
    fi

    if [ "$1" == "" ]; then 
        szAnswer=$(zenity --timeout 30 --entry --text "What are we searching for?" --entry-text ""); echo $szAnswer
    else
        szAnswer="$1"
    fi

    results=($(grep -Rl "$PPLDIR" --exclude-dir=.git -i -e "$szAnswer"))
    
    for ((i=0; i<${#results[@]}; ++i));
    do
        
        FileName[$i]=$(echo ${results[$i]})
        ShortFileName[$i]=$(basename ${FileName[$i]})
        Identifier[$i]="${ShortFileName[$i]%.*}"
        if [ -z "$pplexe" ];then
            PeopleName[$i]=$(grep ${FileName[$i]} -e "FN:" | awk -F ":" '{print $2}')
        else
            PeopleName[$i]=$(ppl name ${Identifier[$i]})
        fi
    done
    #echo "${PeopleName[@]}"
    # if there's only one... maybe skip this step?
    if [ ${#results[@]} == 0 ];then
        zenity --error --text "No matches found!"
        exit
    elif [ ${#results[@]} == 1 ];then
        i=0
    else
        buildstring=$(printf ' FALSE "%s" ' "${PeopleName[@]}")
        choicecmdline="zenity --timeout 30 --list  --text 'Which to display?' --radiolist  --column 'Pick' --column 'Name' $buildstring"
        ChosenName=$(eval "$choicecmdline")
        i=0
        for a in "${PeopleName[@]}"; do
            [[ $a == "$ChosenName" ]] && { echo "$i"; break; }
            (( ++i ))
        done
    fi
    #echo "${PeopleName[$i]}"
    #echo "${Identifier[$i]}"
    if [ -z "$pplexe" ];then
        # This output needs to be cleaned up eventually
        cmdline="cat ${FileName[$i]} | zenity --text-info --width 400 --height 400 --title=${PeopleName[$i]} "
    else
        cmdline="ppl show ${Identifier[$i]} | zenity --text-info --width 400 --height 400 --title=${PeopleName[$i]} "
    fi
    eval "$cmdline"
