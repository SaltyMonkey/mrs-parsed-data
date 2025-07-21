#!/bin/bash
GITHUBLINK="https://raw.githubusercontent.com/SaltyMonkey/mrs-parsed-data/refs/heads/main"

RULESETS_FILEPATH="./rulesets.justclash.txt"
BLOCKRULESETS_FILEPATH="./blockrulesets.justclash.txt"

rm -f $RULESETS_FILEPATH
rm -f $BLOCKRULESETS_FILEPATH
generate_list() {
    local ext="$1"
    local dir="$2"
    local ruletype="$3"
    local readable_name_addon="$4"
    local filename_addon="$5"
    if find "$dir" -type f -name "*.$ext" | grep -q .; then
        find "$dir" -type f -name "*.$ext" | sort | while read -r file; do
            local file_name
            file_name=$(basename "$file" ."$ext")
            local file_path=${file#./}
            local github_path=$GITHUBLINK/$file_path
            local readable_upper_name=${file_name^}
            readable_name=${readable_upper_name//-/ }
            if [ -n "$readable_name_addon" ]; then
                readable_name="$readable_name $readable_name_addon"
            fi
            if [ -n "$filename_addon" ]; then
                file_name="$file_name-$filename_addon"
            fi
            echo "$readable_name|$file_name|$ruletype|$ext|$github_path"
        done
    fi
}

cat <<EOF >> "$RULESETS_FILEPATH"
$(generate_list "mrs" ./bypass "domain")
$(generate_list "mrs" ./services "domain")
$(generate_list "mrs" ./subnets/ipv4 "ipcidr" "CIDR" "ipcidr")

EOF

cat <<EOF >> "$BLOCKRULESETS_FILEPATH"
$(generate_list "mrs" ./ads "domain")
$(generate_list "mrs" ./badware "domain")
EOF