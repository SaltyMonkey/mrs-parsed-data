#!/bin/bash

FOLDER="block/"
#SERVICES_FOLDER="services/"
#All_SERVICES_FILENAME="all_services.lst";
YAMLFOLDER="block/yaml/"
NO_RUSSIA_HOSTS_EXCLUSION_FILE="manual/block/no-russia-hosts-exclusion"

source ./update_shared.sh

mkdir -p "${FOLDER}"
mkdir -p "${YAMLFOLDER}"

rm -f "${FOLDER}"*.txt 2>/dev/null
rm -f "${FOLDER}"*.tmp 2>/dev/null
rm -f "${FOLDER}"*.yaml 2>/dev/null
rm -f "${YAMLFOLDER}"*.yaml 2>/dev/null

exclude_from_no_russia_hosts() {
    local input_file="$1"
    grep -Fvx -f "$NO_RUSSIA_HOSTS_EXCLUSION_FILE" "$input_file" > "${input_file}.filtered"
    mv "${input_file}.filtered" "$input_file"
}

main() {
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-ecommerce-ru.yaml "${FOLDER}"category-ecommerce-ru.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-cdn-\!cn.yaml "${FOLDER}"category-cdn.yaml
    download https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Categories/geoblock.lst "${FOLDER}"itdog-geoblock.txt
    download https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Russia/inside-raw.lst "${FOLDER}"itdog-russia-inside.txt
    download https://raw.githubusercontent.com/GubernievS/AntiZapret-VPN/refs/heads/main/setup/root/antizapret/download/include-hosts.txt "${FOLDER}"guberniev-include.txt
    download https://community.antifilter.download/list/domains.lst "${FOLDER}"antifilter-community.txt
    download https://raw.githubusercontent.com/dartraiden/no-russia-hosts/refs/heads/master/hosts.txt "${FOLDER}"no-russia-hosts.txt
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-gov-ru.yaml "${FOLDER}"category-gov-ru.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-dev.yaml "${FOLDER}"category-dev.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-anticensorship.yaml "${FOLDER}"category-anticensorship.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-speedtest.yaml "${FOLDER}"category-speedtest.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-remote-control.yaml "${FOLDER}"category-remote-control.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-password-management.yaml "${FOLDER}"category-password-management.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-ip-geo-detect.yaml "${FOLDER}"category-ip-geo-detect.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/tldr-ru.yaml "${FOLDER}"category-tldr-ru.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-bank-ru.yaml "${FOLDER}"category-bank-ru.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-retail-ru.yaml "${FOLDER}"category-retail-ru.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-ai-\!cn.yaml "${FOLDER}"category-ai.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/mailru.list "${FOLDER}"mailru.txt
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/kaspersky.list "${FOLDER}"kaspersky.txt
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/drweb.list "${FOLDER}"drweb.txt
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/yandex.list "${FOLDER}"yandex.txt
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-container.yaml "${FOLDER}"category-container.yaml
    download https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-ru.list "${FOLDER}"categ-ru.txt

    exclude_from_no_russia_hosts "${FOLDER}"no-russia-hosts.txt

    ensure_eof_nl "${FOLDER}"mailru.txt "${FOLDER}"kaspersky.txt "${FOLDER}"yandex.txt "${FOLDER}"drweb.txt "${FOLDER}"categ-ru.txt
    cat "${FOLDER}"mailru.txt "${FOLDER}"kaspersky.txt "${FOLDER}"drweb.txt "${FOLDER}"categ-ru.txt | sort | uniq > "${FOLDER}"category-ru.txt
    rm -f "${FOLDER}"categ-ru.txt
    rm -f "${FOLDER}"mailru.txt
    rm -f "${FOLDER}"kaspersky.txt
    rm -f "${FOLDER}"drweb.txt

    #cat "${FOLDER}"guberniev-include.txt "${FOLDER}"itdog-russia-inside.txt "${SERVICES_FOLDER}${All_SERVICES_FILENAME}" | sort | uniq > "${FOLDER}"just-domains.txt
    ensure_eof_nl "${FOLDER}"guberniev-include.txt "${FOLDER}"itdog-russia-inside.txt
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
