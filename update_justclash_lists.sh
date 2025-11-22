#!/bin/bash
JSDELIVR="https://cdn.jsdelivr.net/gh/saltymonkey/mrs-parsed-data"

RULESETS_FILEPATH="./rulesets.txt"
BLOCKRULESETS_FILEPATH="./block.rulesets.txt"

rm -f "$RULESETS_FILEPATH"
rm -f "$BLOCKRULESETS_FILEPATH"
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
            local github_path=$JSDELIVR/$file_path
            local readable_upper_name=${file_name^}
            readable_name=${readable_upper_name//-/ }
            readable_name=$(echo "$readable_name" | sed '
                s/\bru\b/RU/gi;
                s/\brussia\b/Russia/gi;
                s/\bads\b/ADS/gi;
                s/\bnsfw\b/NSFW/gi;
                s/\bdns\b/DNS/gi;
                s/\bibm\b/IBM/gi;
                s/\bovh\b/OVH/gi;
                s/\bqt\b/QT/gi;
                s/\bamd\b/AMD/gi;
                s/\bgpt\b/GPT/gi;
            ')
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
$(generate_list "mrs" ./block "domain")
$(generate_list "mrs" ./services "domain")
$(generate_list "mrs" ./subnets/ipv4 "ipcidr" "CIDR" "ipcidr")

EOF

cat <<EOF >> "$BLOCKRULESETS_FILEPATH"
$(generate_list "mrs" ./ads "domain")
$(generate_list "mrs" ./badware "domain")
EOF