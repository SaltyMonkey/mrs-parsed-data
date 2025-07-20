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
    download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.winoffice.txt "${FOLDER}"hagezi-spy-winoffice.txt
    download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.apple.txt "${FOLDER}"hagezi-spy-apple.txt
    download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.xiaomi.txt "${FOLDER}"hagezi-spy-xiaomi.txt
    download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.huawei.txt "${FOLDER}"hagezi-spy-huawei.txt
    download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.lgwebos.txt "${FOLDER}"hagezi-spy-lgwebos.txt
    download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.oppo-realme.txt "${FOLDER}"hagezi-spy-opporealme.txt
    download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.vivo.txt "${FOLDER}"hagezi-spy-vivo.txt
    download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.samsung.txt "${FOLDER}"hagezi-spy-samsung.txt

    local file
    find "${FOLDER}" -type f -name "*.txt" | while IFS= read -r file; do
        echo "Processing: $file"
        local tmp_file=${file%.*}.tmp
        local yaml_file=${file%.*}.yaml
        local rms_file=${file%.*}.rms
        cleanup "${file}" "${tmp_file}"
        yaml_subdomains "${tmp_file}" "${yaml_file}"
        mrs_domain "${yaml_file}" "${rms_file}"
    done

    mv  "$FOLDER"*.yaml "$YAMLFOLDER"
    rm -f "$FOLDER"*.txt 2>/dev/null
    rm -f "$FOLDER"*.tmp 2>/dev/null
}

main