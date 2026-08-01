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
ContactsDir="$HOME/.contacts"
MuttStyle="false"
VOIPStyle="false"
CliOnly="false"
APPDIR=$(dirname "$(realpath "$0")")
source "$APPDIR/vcardreader.sh"
RealPathSub=""
Query=""
# My individual vcf files are in this directory

##############################################################################
# Entry Chooser
##############################################################################

choose_entry() {
    declare -a Name=()
    declare -a VCARD_Filename=()

    while IFS=$'\t' read -r Filename NameField; do
        Name+=("${NameField}")
        VCARD_Filename+=("${Filename}")
    done < <(
        rg -H -g '*.vcf' '(^BEGIN:VCARD|^FN:[^[:space:]].*)' "$ContactsDir" | \
        awk '
            {
                split($0, parts, ":")
                filename=parts[1]
                line=substr($0, length(filename) + 2)
                sub(/\r$/, "", line)

                if (line == "BEGIN:VCARD") {
                    begins[filename]++
                } else if (line ~ /^FN:[^[:space:]].*/ && !(filename in fn)) {
                    fn[filename]=substr(line, 4)
                }
            }
            END {
                for (filename in begins) {
                    if (begins[filename] == 1 && (filename in fn) && fn[filename] != "") {
                        printf "%s\t%s\n", filename, fn[filename]
                    }
                }
            }
        '
    )

    # Using fzf and rofi here REALLY took a lot of speed and weight off
    if [ "$CliOnly" == "true" ];then
		if [ "$VOIPStyle" == "true" ];then        
        Index="$(for i in "${!Name[@]}"; do
                printf '%s\t%s\t%s\n' "${i}" "${Name[${i}]}" "${VCARD_Filename[${i}]}"
                done | fzf \
                -q "${Query}" --no-hscroll --height 100% --border --ansi --no-bold --header "Whose Vcard?" --delimiter=$'\t' --with-nth=2 --preview "$APPDIR/vcardreader.sh {3}"  \
                | awk -F '\t' '{print $1}')"
		else
        Index="$(for i in "${!Name[@]}"; do
                printf '%s\t%s\t%s\n' "${i}" "${Name[${i}]}" "${VCARD_Filename[${i}]}"
                done | fzf \
                -q "${Query}" --no-hscroll --height 50% --border --ansi --no-bold --header "Whose Vcard?" --delimiter=$'\t' --with-nth=2 --preview "$APPDIR/vcardreader.sh {3}"  \
                | awk -F '\t' '{print $1}')"		
		fi
        SelectedVcard=$(printf '%s\n' "${VCARD_Filename[${Index}]}")
        #SelectedVcard=$(rg "FN:" /home/steven/.contacts/nextcloud/contacts/* | awk -F ':' '{print $3 ":" $1 }' | fzf -q "${Query}" --no-hscroll -m --height 50% --border --ansi --no-bold --header "Whose Vcard?" --preview="$SCRIPTDIR/vcardreader.sh {}"  | awk -F ':' '{print $2}' )
    else
        # way more complicated for rofi, and not my main use case.
        Index="$(for i in "${!Name[@]}"; do
                printf '%s\t%s\n' "${Name[${i}]}" "${VCARD_Filename[${i}]}"
                done | rofi -i -dmenu -p "Whose Vcard?" | awk -F '\t' '{print $2}')"
        SelectedVcard=$(printf '%s\n' "${Index}")
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
		if [ "$VOIPStyle" == "true" ];then
			num_phones=$(echo -e "$result" | rg -c -e "☎" )
            if [[ "$num_phones" -gt 1 ]];then
                echo "$result" | rg -e "☎" | fzf --no-hscroll -m --height 50% --border --ansi --no-bold --header "Which phone number?" | awk -F ': ' '{print $2}'
            else
                echo "$result" | rg -e "☎" | awk -F ': ' '{print $2 }'
            fi
            # exit the program here! It's for voip, we just want phone.
            exit 0
		fi
			
        if [ "$MuttStyle" == "true" ];then
            num_emails=$(echo -e "$result" | rg -c -e "✉" )
            if [[ "$num_emails" -gt 1 ]];then
                echo "$result" | rg -e "✉" | fzf --no-hscroll -m --height 50% --border --ansi --no-bold --header "Which email address?" | awk -F ': ' '{print $2}'
            else
                echo "$result" | rg -e "✉" | awk -F ': ' '{print $2 }'
            fi
            # exit the program here! It's for mutt, we just want email.
            exit 0
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
    echo "# -v returning only the phone, for linphone, etc, implies cli only)"
    echo "# -c cli/tui interface only "
    echo "###################################################################"
}

##############################################################################
# Sort out commandline options
##############################################################################

while [ $# -gt 0 ]; do
option="$1"
    case $option in
    -v) VOIPStyle="true"
        CliOnly="true"
        shift ;;
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
