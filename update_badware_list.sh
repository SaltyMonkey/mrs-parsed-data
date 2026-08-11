#!/bin/bash

FOLDER="badware/"
YAMLFOLDER="badware/yaml/"


source ./update_shared.sh

mkdir -p "${FOLDER}"
mkdir -p "${YAMLFOLDER}"

rm -f "${FOLDER}"*.txt 2>/dev/null
rm -f "${FOLDER}"*.tmp 2>/dev/null
rm -f "${FOLDER}"*.yaml 2>/dev/null
rm -f "${YAMLFOLDER}"*.yaml 2>/dev/null

main() {
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.winoffice.txt "${FOLDER}"hagezi-spy-winoffice.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.apple.txt "${FOLDER}"hagezi-spy-apple.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.xiaomi.txt "${FOLDER}"hagezi-spy-xiaomi.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.huawei.txt "${FOLDER}"hagezi-spy-huawei.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.lgwebos.txt "${FOLDER}"hagezi-spy-lgwebos.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.oppo-realme.txt "${FOLDER}"hagezi-spy-opporealme.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.vivo.txt "${FOLDER}"hagezi-spy-vivo.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.amazon.txt "${FOLDER}"hagezi-spy-amazon.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.samsung.txt "${FOLDER}"hagezi-spy-samsung.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.tiktok.txt "${FOLDER}"hagezi-spy-tiktok.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/dyndns.txt "${FOLDER}"hagezi-dyndns.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/hoster.txt "${FOLDER}"hagezi-badware-hosters.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/social.txt "${FOLDER}"hagezi-social-network.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/fake.txt "${FOLDER}"hagezi-fakes-scam-trap.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/tif.txt "${FOLDER}"hagezi-tif.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/tif.mini.txt "${FOLDER}"hagezi-tif-mini.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/gambling.mini.txt "${FOLDER}"hagezi-gambling-mini.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/gambling.medium.txt "${FOLDER}"hagezi-gambling-medium.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/urlshortener.txt "${FOLDER}"hagezi-url-shorteners.txt
    download https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/anti.piracy.txt "${FOLDER}"hagezi-antipiracy.txt
    local file
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
