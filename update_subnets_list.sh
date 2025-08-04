#!/bin/bash

FOLDER="subnets/"

source ./update_shared.sh

mkdir -p "${FOLDER}"
mkdir -p "${FOLDER}"ipv4/
mkdir -p "${FOLDER}"ipv6/
mkdir -p "${FOLDER}"dual/

find "${FOLDER}" -type f -name "*.txt" -exec rm -f {} +
find "${FOLDER}" -type f -name "*.tmp" -exec rm -f {} +
find "${FOLDER}" -type f -name "*.yaml" -exec rm -f {} +
find "${FOLDER}" -type f -name "*.json" -exec rm -f {} +

main() {
    download "https://www.cloudflare.com/ips-v4" "${FOLDER}"ipv4/cloudflare.txt
    download "https://www.cloudflare.com/ips-v6" "${FOLDER}"ipv6/cloudflare.txt
    download "https://iplist.opencck.org/?format=text&data=cidr4&site=discord.gg" "${FOLDER}"ipv4/discord-voice.txt
    download "https://iplist.opencck.org/?format=text&data=cidr6&site=discord.gg" "${FOLDER}"ipv6/discord-voice.txt
    download "https://community.antifilter.download/list/community.lst" "${FOLDER}"ipv4/antifilter-community.txt
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geoip/apple.yaml" "${FOLDER}"ipv4/apple.yaml

    download "https://bgp.tools/table.txt" "${FOLDER}"table.txt
    get_cidrs_by_asn 24940 "${FOLDER}"table.txt "${FOLDER}"dual/hetzner.txt
    get_cidrs_by_asn 16276 "${FOLDER}"table.txt "${FOLDER}"dual/ovh.txt
    split_subnets "${FOLDER}"dual/hetzner.txt "${FOLDER}"ipv4/hetzner.txt "${FOLDER}"ipv6/hetzner.txt
    split_subnets "${FOLDER}"dual/ovh.txt "${FOLDER}"ipv4/ovh.txt "${FOLDER}"ipv6/ovh.txt
    rm -rf "${FOLDER}"table.txt

    download "https://core.telegram.org/resources/cidr.txt" "${FOLDER}"dual/telegram.txt
    split_subnets "${FOLDER}"dual/telegram.txt "${FOLDER}"ipv4/telegram.txt "${FOLDER}"ipv6/telegram.txt

    download "https://d7uri8nf7uskq.cloudfront.net/tools/list-cloudfront-ips" "${FOLDER}"ipv4/cloudfront.json
    parse_json "${FOLDER}"ipv4/cloudfront.json "${FOLDER}"ipv4/cloudfront.txt

    echo >> "${FOLDER}"ipv4/cloudflare.txt
    cat "${FOLDER}"ipv4/cloudflare.txt "${FOLDER}"ipv6/cloudflare.txt | sort | uniq > "${FOLDER}"dual/cloudflare.txt

    echo >> "${FOLDER}"ipv4/discord-voice.txt
    cat "${FOLDER}"ipv4/discord-voice.txt "${FOLDER}"ipv6/discord-voice.txt | sort | uniq > "${FOLDER}"dual/discord-voice.txt

    local file


    find "${FOLDER}" -type f -name "*.yaml" | while IFS= read -r file; do
        echo "Processing YAML: $file"
        local mrs_file=${file%.*}.mrs
        mrs_ipcidr "${file}" "${mrs_file}"
    done

    find "${FOLDER}" -type f -name "*.txt" | while IFS= read -r file; do
        echo "Processing: $file"
        local tmp_file="${file%.*}.tmp"
        local yaml_file="${file%.*}.yaml"
        local mrs_file="${file%.*}.mrs"
        cleanup "${file}" "${tmp_file}"
        yaml "${tmp_file}" "${yaml_file}"
        mrs_ipcidr "${yaml_file}" "${mrs_file}"
    done

    find "${FOLDER}" -type f -name "*.txt" -exec rm -f {} +
    find "${FOLDER}" -type f -name "*.tmp" -exec rm -f {} +
    find "${FOLDER}" -type f -name "*.yaml" -exec rm -f {} +
    find "${FOLDER}" -type f -name "*.json" -exec rm -f {} +
}

main