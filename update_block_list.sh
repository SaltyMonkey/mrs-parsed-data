#!/bin/bash

FOLDER="block/"
#SERVICES_FOLDER="services/"
#All_SERVICES_FILENAME="all_services.lst";
YAMLFOLDER="block/yaml/"

source ./update_shared.sh

mkdir -p "${FOLDER}"
mkdir -p "${YAMLFOLDER}"

rm -f "${FOLDER}"*.txt 2>/dev/null
rm -f "${FOLDER}"*.tmp 2>/dev/null
rm -f "${FOLDER}"*.yaml 2>/dev/null
rm -f "${YAMLFOLDER}"*.yaml 2>/dev/null

main() {
    download https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Russia/inside-raw.lst "${FOLDER}"itdog-russia-inside.txt
    download https://raw.githubusercontent.com/GubernievS/AntiZapret-VPN/refs/heads/main/setup/root/antizapret/download/include-hosts.txt "${FOLDER}"guberniev-include.txt
    download https://community.antifilter.download/list/domains.lst "${FOLDER}"antifilter-community.txt
    download https://raw.githubusercontent.com/dartraiden/no-russia-hosts/refs/heads/master/hosts.txt "${FOLDER}"no-russia-hosts.txt
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-gov-ru.yaml "${FOLDER}"category-gov-ru.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-ru.yaml "${FOLDER}"category-ru.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-dev.yaml "${FOLDER}"category-dev.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-speedtest.yaml "${FOLDER}"category-speedtest.yaml

    #cat "${FOLDER}"guberniev-include.txt "${FOLDER}"itdog-russia-inside.txt "${SERVICES_FOLDER}${All_SERVICES_FILENAME}" | sort | uniq > "${FOLDER}"just-domains.txt
    cat "${FOLDER}"guberniev-include.txt "${FOLDER}"itdog-russia-inside.txt | sort | uniq > "${FOLDER}"just-domains.txt
    rm -f "${FOLDER}"guberniev-include.txt

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
        mrs_domain "${yaml_file}" "${mrs_file}"
    done

    mv  "$FOLDER"*.yaml "$YAMLFOLDER"
    rm -f "${FOLDER}"*.txt 2>/dev/null
    rm -f "${FOLDER}"*.tmp 2>/dev/null

}

main