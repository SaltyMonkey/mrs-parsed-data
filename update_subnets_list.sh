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
    download "https://iplist.opencck.org/?format=text&data=cidr4&site=discord.gg&site=discord.media" "${FOLDER}"ipv4/discord.txt
    download "https://iplist.opencck.org/?format=text&data=cidr6&site=discord.gg&site=discord.media" "${FOLDER}"ipv6/discord.txt
    download "https://community.antifilter.download/list/community.lst" "${FOLDER}"ipv4/antifilter-community.txt

    download "https://core.telegram.org/resources/cidr.txt" "${FOLDER}"dual/telegram.txt
    split_subnets "${FOLDER}"dual/telegram.txt "${FOLDER}"ipv4/telegram.txt "${FOLDER}"ipv6/telegram.txt

    download "https://d7uri8nf7uskq.cloudfront.net/tools/list-cloudfront-ips" "${FOLDER}"ipv4/cloudfront.json
    parse_json "${FOLDER}"ipv4/cloudfront.json "${FOLDER}"ipv4/cloudfront.txt

    echo >> "${FOLDER}"ipv4/cloudflare.txt
    cat "${FOLDER}"ipv4/cloudflare.txt "${FOLDER}"ipv6/cloudflare.txt | sort | uniq > "${FOLDER}"dual/cloudflare.txt

    echo >> "${FOLDER}"ipv4/discord.txt
    cat "${FOLDER}"ipv4/discord.txt "${FOLDER}"ipv6/discord.txt | sort | uniq > "${FOLDER}"dual/discord.txt

    local file
    find "${FOLDER}" -type f -name "*.txt" | while IFS= read -r file; do
        echo "Processing: $file"
        local tmp_file="${file%.*}.tmp"
        local yaml_file="${file%.*}.yaml"
        local rms_file="${file%.*}.rms"
        cleanup "${file}" "${tmp_file}"
        yaml "${tmp_file}" "${yaml_file}"
        mrs_ipcidr "${yaml_file}" "${rms_file}"
    done

    find "${FOLDER}" -type f -name "*.txt" -exec rm -f {} +
    find "${FOLDER}" -type f -name "*.tmp" -exec rm -f {} +
    find "${FOLDER}" -type f -name "*.yaml" -exec rm -f {} +
    find "${FOLDER}" -type f -name "*.json" -exec rm -f {} +
}

main