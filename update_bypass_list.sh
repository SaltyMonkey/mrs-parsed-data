#!/bin/bash

FOLDER="bypass/"
MANUAL_FOLDER="manual/"
SERVICES_FOLDER=FOLDER="services/"
All_SERVICES_FILENAME="all_services.lst";

download() {
    local uri="$1"
    local output_path="$2"
    local code
    curl -sL "${uri}" -o "${output_path}"
    code=$?
    if [ $code -ne 0 ]; then
        echo "Curl failed with exit code $code"
    fi
}

cleanup() {
    local input_file="$1"
    local output_file="$2"
    grep -v -E '^\s*#|^\s*$' $input_file > $output_file
}

yaml() {
    local input_file="$1"
    local output_file="$2"
    echo "payload:" > "${output_file}"
    cat "$input_file" | sed "s/.*/  - '+.&'/" >> $output_file
}

mrs() {
    local input_file="$1"
    local output_file="$2"
    ./mihomo convert-ruleset domain yaml ${input_file} ${output_file}
}

mkdir -p ${FOLDER}
rm -f ${FOLDER}*.txt 2>/dev/null
rm -f ${FOLDER}*.tmp 2>/dev/null
rm -f ${FOLDER}*.yaml 2>/dev/null

main() {
    download https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Russia/inside-raw.lst ${FOLDER}itdog-russia-inside.txt
    download https://raw.githubusercontent.com/GubernievS/AntiZapret-VPN/refs/heads/main/setup/root/antizapret/download/include-hosts.txt ${FOLDER}guberniev-include.txt
    download https://community.antifilter.download/list/domains.lst ${FOLDER}antifilter-community.txt
    download https://raw.githubusercontent.com/dartraiden/no-russia-hosts/refs/heads/master/hosts.txt ${FOLDER}no-russia-hosts

    grep -v -F -x -f ${MANUAL_FOLDER}excluded-no-russia-hosts ${FOLDER}no-russia-hosts > ${FOLDER}no-russia-hosts.txt
    rm -r ${FOLDER}no-russia-hosts

    cat ${FOLDER}guberniev-include.txt ${FOLDER}itdog-russia-inside.txt ${SERVICES_FOLDER}${All_SERVICES_FILENAME} | sort | uniq > ${FOLDER}just-domains.txt
    rm -r ${FOLDER}guberniev-include.txt

    local file
    find ${FOLDER} -type f -name "*.txt" | while IFS= read -r file; do
        echo "Processing: $file"
        local tmp_file=${file%.*}.tmp
        local yaml_file=${file%.*}.yaml
        local rms_file=${file%.*}.rms
        cleanup "${file}" "${tmp_file}"
        yaml "${tmp_file}" "${yaml_file}"
        mrs "${yaml_file}" "${rms_file}"

    done

    rm -f ${FOLDER}*.txt 2>/dev/null
    rm -f ${FOLDER}*.tmp 2>/dev/null
    rm -f ${FOLDER}*.yaml 2>/dev/null

}

main