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
    download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/wildcard/pro.plus.mini.txt "${FOLDER}"hagezi-pro-plus-mini-ads.txt
    download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/wildcard/light.txt "${FOLDER}"hagezi-light-ads.txt
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/google-ads.yaml "${FOLDER}"google-ads.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-ads-all.yaml "${FOLDER}category-ads-all.yaml"

    local file

    find "${FOLDER}" -type f -name "*.yaml" | while IFS= read -r file; do
        echo "Processing YAML: $file"
        local mrs_file=${file%.*}.mrs
        yaml_sort_by_alphabet "$file" "$file" "payload"
        mrs_domain "${file}" "${mrs_file}"
    done

    find "${FOLDER}" -type f -name "*.txt" | while IFS= read -r file; do
        echo "Processing: $file"
        local tmp_file=${file%.*}.tmp
        local yaml_file=${file%.*}.yaml
        local mrs_file=${file%.*}.mrs
        cleanup "${file}" "${tmp_file}"
        yaml_subdomains "${tmp_file}" "${yaml_file}"
        yaml_sort_by_alphabet "$yaml_file" "$yaml_file" "payload"
        mrs_domain "${yaml_file}" "${mrs_file}"
    done

    mv  "$FOLDER"*.yaml "$YAMLFOLDER"
    rm -f "$FOLDER"*.txt 2>/dev/null
    rm -f "$FOLDER"*.tmp 2>/dev/null
}

main