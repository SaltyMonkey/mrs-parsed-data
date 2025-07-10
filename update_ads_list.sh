#!/bin/bash

FOLDER="ads/"
YAMLFOLDER="ads/yaml/"

source ./update_shared.sh

mkdir -p "${FOLDER}"
mkdir -p "${YAMLFOLDER}"

rm -f "${FOLDER}"*.txt 2>/dev/null
rm -f "${FOLDER}"*.tmp 2>/dev/null
rm -f "${FOLDER}"*.yaml 2>/dev/null
rm -f "${YAMLFOLDER}"*.yaml 2>/dev/null

main() {
    download https://nsfw-small.oisd.nl/domainswild "${FOLDER}"oisd-nsfw-small.txt
    download https://small.oisd.nl/domainswild "${FOLDER}"oisd-small.txt
    download https://nsfw.oisd.nl/domainswild "${FOLDER}"oisd-nsfw.txt
    download https://big.oisd.nl/domainswild "${FOLDER}"oisd-big.txt
    download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/wildcard/pro.txt "${FOLDER}"hagezi-pro-ads.txt
    download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/wildcard/pro.mini.txt "${FOLDER}"hagezi-pro-mini-ads.txt
    download "https://beta.iplist.opencck.org/?format=text&data=domains&site=google%40google-ads" "${FOLDER}"google-ads.txt

    local file
    find "${FOLDER}" -type f -name "*.txt" | while IFS= read -r file; do
        echo "Processing: $file"
        local tmp_file=${file%.*}.tmp
        local yaml_file=${file%.*}.yaml
        local rms_file=${file%.*}.rms
        cleanup "${file}" "${tmp_file}"
        yaml "${tmp_file}" "${yaml_file}"
        mrs_domain "${yaml_file}" "${rms_file}"
    done

    mv  "$FOLDER"*.yaml "$YAMLFOLDER"
    rm -f "$FOLDER"*.txt 2>/dev/null
    rm -f "$FOLDER"*.tmp 2>/dev/null
}

main