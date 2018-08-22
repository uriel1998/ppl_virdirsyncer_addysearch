#!/bin/bash

########################################################################
# For some reason my DAVDroid contacts were sometimes missing the N:
# field and driving ppl nuts. This will hopefully fix that.
########################################################################


    if [ -f ~/.pplconfig ];then
        PPLDIR=$(sed -n '/[addressbook]/{n;p;}' ~/.pplconfig | awk -F "= " '{print $2}')
    else
        PPLDIR=$PWD
    fi

    find "$PPLDIR" -iname "*.vcf" | while read vcard
    do
        Name=$(grep "$vcard" -e "^N:" | awk -F ":" '{print $2}')
        if [ -z "$Name" ];then
            TempName=$(grep "$vcard" -e "^FN:" | awk -F ":" '{print $2 }' | tr -d '\r')
            PeopleName=$(echo "$TempName" | awk '{print $2";"$1 }')
            TempFile=$(mktemp)
            OLD_IFS="$IFS"
            IFS=
            while read line
            do
                echo "$line" | grep -q -e "^FN:"
                if [ $? -eq 0 ];then 
                    echo "$line" >> "$TempFile"
                    echo "N:$PeopleName;;;"  >> "$TempFile" 
                else
                    echo "$line" >> "$TempFile"
                fi
            done < "$vcard"
            rm "$vcard"
            cp -f "$TempFile" "$vcard"
            rm "$TempFile"  
            IFS="$OLD_IFS"
        fi
        END=$(grep "$vcard" -e "^END:VCARD")
        if [ -z "$END" ];then
            echo "END:VCARD" >> "$vcard"
        fi
	done
