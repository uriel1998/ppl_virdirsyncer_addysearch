#!/bin/bash
  
##############################################################################
# vcardreader, by Steven Saus 24 July 2020
# steven@stevesaus.com
# Licenced under the MIT License
##############################################################################  
    
# because this is a bash function, it's using the input variable $SelectedVcard 
# and the arrays as the returned
# variable.  So there's no real "return" other than setting that var.
# This only outputs results to STDOUT if run as a standalone program.


function read_vcard {
    cat "$SelectedVcard" | while read line ; do

    if [[ $line = EMAIL* ]]; then
        #starts it at one!
        (( ++num_emails ))
        # removing the non-standardized "PREF" string 
        temp=$(echo "$line" | awk -F = '{ print $2 }' | awk -F : '{print $1}' | awk '{print tolower($0)}' | sed 's/pref//' | sed 's/,//' )
        if [ -z "$temp" ];then
            email_type[$num_emails]="main"
        else
            email_type[$num_emails]=$(echo "$temp")
        fi
            
        temp=""
        temp=$(echo "$line" | awk -F ':' '{print $2}')
        email[$num_emails]=${temp//[$'\t\r\n']}
        line=""
    fi
    if [[ $line = ORG:* ]]; then
        org=${line#*:}
    fi
    
    if [[ "$line" =~ "ADR;" ]]; then
        (( ++num_adr ))
        # removing the non-standardized "PREF" string 
        temp=$(echo "$line" | awk -F = '{ print $2 }' | awk -F : '{print $1}' | awk '{print tolower($0)}' | sed 's/pref//' | sed 's/;label//'| sed 's/,//' )
        
        if [ -z "$temp" ];then
            adr_type[$num_adr]="none"
        else
            adr_type[$num_adr]=$(echo "$temp")
        fi
        adr_type[$num_adr]=${temp//[$'\t\r\n']}
        temp=""    
        # testing to see if the address continues, using grep, of all things.
        testcount=$(grep ADR --after-context=1 "${SelectedVcard}" | tail -1 | grep -c -e "^\ ")
        if [ $testcount -gt 0 ];then
            line=$(grep ADR --after-context=1 "${SelectedVcard}" | sed 's/^[[:space:]]*//')
            line=${line//[$'\t\r\n']}
        fi
        temp=$(echo "$line" | awk -F ':' '{print $2}' | sed 's/;/,/g' | sed 's/^,,//' | sed 's/,,/,/g' )
        temp=${temp//[$'\t\r\n']}
        address[$num_adr]=$(echo "$temp" | sed 's/,$//')

        line=""    
    fi
    
    if [[ "$line" =~ "TEL;" ]]; then
        (( ++num_tels ))
        # removing the non-standardized "PREF" string 
        temp=$(echo "$line" | awk -F = '{ print $2 }' | awk -F : '{print $1}' | awk '{print tolower($0)}' | sed 's/pref//' | sed 's/,//' )
        if [ -z "$temp" ];then
            tel_type[$num_tels]="none"
        else
            tel_type[$num_tels]=$(echo "$temp")
        fi
        tel_type[$num_tels]=${temp//[$'\t\r\n']}
        temp=""    
        temp=$(echo "$line" | awk -F ':' '{print $2}')
        tel_num[$num_tels]=${temp//[$'\t\r\n']}
        line=""    
    fi
    #TODO catch if not FN, put together
    if [[ $line = FN:* ]]; then
        full_name=${line#*:}
    fi
    if [[ "$line" =~ "END:VCARD" ]]; then
        echo "  ✢ $full_name"
        if [ ! -z "$org" ];then
            echo "  ☖ $org"
        fi
        START=1
        END="${num_tels[@]}"
        if [[ $END -gt 0 ]];then
            for (( c=$START; c<=$END; c++ ));do
                printf "  ☎ %s: %s \n" "${tel_type[c]}" "${tel_num[c]}" 
            done
        else
            printf "  ☎ No Phone number \n"
            #printf "%s: %s \n" "${tel_type[0]}" "${tel_num[0]}" 
        fi
        
        START=1
        END="${num_adr[@]}"
        if [[ $END -gt 1 ]];then
            for (( c=$START; c<=$END; c++ ));do
                printf "  🏚 %s: %s\n" "${adr_type[c]}" "${address[c]}" 
            done
        else 
            printf "  🏚 %s: %s\n" "${adr_type[1]}" "${address[1]}" 
        fi
        
        START=1
        END="${num_emails[@]}"
        if [[ $END -gt 1 ]];then
            for (( c=$START; c<=$END; c++ ));do
                printf "  ✉ %s: %s\n" "${email_type[c]}" "${email[c]}" 
            done
        else 
            printf "  ✉ %s: %s\n" "${email_type[1]}" "${email[1]}" 
        fi        
    fi

    done

}




##############################################################################
# Are we sourced?
# From http://stackoverflow.com/questions/2683279/ddg#34642589
##############################################################################

# Try to execute a `return` statement,
# but do it in a sub-shell and catch the results.
# If this script isn't sourced, that will raise an error.
$(return >/dev/null 2>&1)

# What exit code did that give?
if [ "$?" -eq "0" ];then
    #echo "[info] Function read_vcard ready to go."
    OUTPUT=0
else
    OUTPUT=1
    if [ "$#" = 0 ];then
        echo "Please call this as a function or with the filename as the first argument."
    else
        if [ -f "$1" ];then
            SelectedVcard="$1"
        else
            #if it's coming from pplsearch for preview
            SelectedVcard=$(echo "$1" | awk -F ':' '{print $2}' | xargs -I {} realpath {} )
        fi
        if [ ! -f "$SelectedVcard" ];then
            echo "File not found..."
            exit 1
        fi
        SUCCESS=0
        output=$(read_vcard)
        if [ $SUCCESS -eq 0 ];then
            # If it gets here, it has to be standalone
                echo "$output"
        else
            exit 99
        fi
    fi
fi

