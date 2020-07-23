#!/bin/bash
  
##############################################################################
# muna, by Steven Saus 3 May 2020
# steven@stevesaus.com
# Licenced under the Apache License
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
        temp=$(echo "$line" | awk -F = '{ print $2 }' | awk -F : '{print $1}' )
        if [ -z "$temp" ];then
            email_type[$num_emails]="none"
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
    if [[ "$line" =~ "TEL;" ]]; then
        (( ++num_tels ))
        temp=$(echo "$line" | awk -F = '{ print $2 }' | awk -F : '{print $1}')
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
        echo "$full_name"
        echo "$org"
        START=1
        END="${num_tels[@]}"
        for (( c=$START; c<=$END; c++ ));do
            printf "%s: %s \n" "${tel_type[c]}" "${tel_num[c]}" 
        done
        
        START=1
        END="${num_emails[@]}"
        for (( c=$START; c<=$END; c++ ));do
            printf "%s %s\n" "${email[c]}" "${email_type[c]}"
            
        done
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
    echo "[info] Function read_vcard ready to go."
    OUTPUT=0
else
    OUTPUT=1
    if [ "$#" = 0 ];then
        echo "Please call this as a function or with the filename as the first argument."
    else
        SelectedVcard="$1"
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

