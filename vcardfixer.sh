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

    find "$PPLDIR" -iname "*.vcf" | while read -r vcard
    do
        Name=$(grep -e "^N:" "$vcard" | awk -F ":" '{print $2}')
        if [ -z "$Name" ];then
            TempName=$(grep -e "^FN:" "$vcard" | awk -F ":" '{print $2 }' | tr -d '\r')
            PeopleName=$(echo "$TempName" | awk '{print $2";"$1 }')
            TempFile=$(mktemp)
            OLD_IFS="$IFS"
            IFS=
            while read -r line
            do
                echo "$line" | grep -q -e "^FN:"
                if [ $? -eq 0 ];then
                    echo "$line" >> "$TempFile"
                    echo "N:$PeopleName;;;" >> "$TempFile"
                else
                    echo "$line" >> "$TempFile"
                fi
            done < "$vcard"
            rm "$vcard"
            cp -f "$TempFile" "$vcard"
            rm "$TempFile"  
            IFS="$OLD_IFS"
        fi
        END=$(grep -e "^END:VCARD" "$vcard")
        if [ -z "$END" ];then
            echo "END:VCARD" >> "$vcard"
        fi
	done
