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
        echo "Who are we searching for?"
        read szAnswer
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
        echo "No matches found!"
        exit
    else
        END="${#results[@]}"
        (( --END ))
        if [ "$i" == "1" ];then
            choicenum="0"
        else
            TEMPFILE=$(mktemp)
            printf '\n' > $TEMPFILE
            for ((i=0;i<=END;i++)); do
                printf '%s %s\n' "$i" "${PeopleName[$i]}" >> $TEMPFILE
            done
            choice=$(cat "$TEMPFILE" | pick)
            rm "$TEMPFILE"
            choicenum=$(echo "$choice" | awk -F ' ' '{print $1}')
        fi




        email=$(ppl email ${Identifier[$choicenum]} | pick | xargs)
        FullName=$(ppl name ${Identifier[$choicenum]} | xargs)
        printf "%s\n" "$email" | tee >(xsel -i --primary) >(xsel -i --secondary) >(xsel -i --clipboard)
    fi
