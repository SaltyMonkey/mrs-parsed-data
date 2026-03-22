#!/bin/bash

FOLDER="subnets/"

source ./update_shared.sh

readonly BGPQ4_SOURCES="RPKI,AFRINIC,APNIC,ARIN,LACNIC,RIPE"

CONTABO_ASNS=(51167 141995)
AKAMAI_ASNS=(20940 63949)
ROBLOX_ASNS=(22697)
SCALEWAY_ASNS=(12876)
SCALAXY_ASNS=(58061)
CDN77_ASNS=(60068)
DATACAMP_ASNS=(212238)
CLOUDFLARE_ASNS=(13335)
HETZNER_ASNS=(24940)
OVH_ASNS=(16276)
DIGITALOCEAN_ASNS=(14061)
BUNNY_ASNS=(200325)
META_ASNS=(32934)
TELEGRAM_ASNS=(62041 62014 211157 44907 59930)
GCORE_ASNS=(199524 202422)
FASTLY_ASNS=(54113)

mkdir -p "${FOLDER}"
mkdir -p "${FOLDER}"ipv4/
mkdir -p "${FOLDER}"ipv6/
mkdir -p "${FOLDER}"dual/

find "${FOLDER}" -type f -name "*.txt" -exec rm -f {} +
find "${FOLDER}" -type f -name "*.tmp" -exec rm -f {} +
find "${FOLDER}" -type f -name "*.yaml" -exec rm -f {} +
find "${FOLDER}" -type f -name "*.json" -exec rm -f {} +

run_bgpq4() {
    local family="$1"
    local output_file="$2"
    local truncate_output="$3"
    shift 3

    if [ "${truncate_output}" = "true" ]; then
        : > "${output_file}"
    fi

    local asn
    for asn in "$@"; do
        bgpq4 -S "${BGPQ4_SOURCES}" -A -F "%n/%l\n" "${family}" "as${asn}" >> "${output_file}"
        ensure_eof_nl "${output_file}"
    done
}

generate_asn_lists() {
    local name="$1"
    shift

    run_bgpq4 -4 "${FOLDER}ipv4/${name}.txt" true "$@"
    run_bgpq4 -6 "${FOLDER}ipv6/${name}.txt" true "$@"
    cat "${FOLDER}ipv4/${name}.txt" "${FOLDER}ipv6/${name}.txt" | sort | uniq > "${FOLDER}dual/${name}.txt"
}

main() {
    download "https://iplist.opencck.org/?format=text&data=cidr4&site=discord.gg" "${FOLDER}"ipv4/discord-voice.txt
    download "https://iplist.opencck.org/?format=text&data=cidr6&site=discord.gg" "${FOLDER}"ipv6/discord-voice.txt
    download "https://community.antifilter.download/list/community.lst" "${FOLDER}"ipv4/antifilter-community.txt
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geoip/apple.yaml" "${FOLDER}"ipv4/apple.yaml

    generate_asn_lists "contabo" "${CONTABO_ASNS[@]}"
    generate_asn_lists "akamai" "${AKAMAI_ASNS[@]}"
    generate_asn_lists "roblox" "${ROBLOX_ASNS[@]}"
    generate_asn_lists "scaleway" "${SCALEWAY_ASNS[@]}"
    generate_asn_lists "scalaxy" "${SCALAXY_ASNS[@]}"
    generate_asn_lists "cdn77" "${CDN77_ASNS[@]}"
    generate_asn_lists "datacamp" "${DATACAMP_ASNS[@]}"
    generate_asn_lists "cloudflare" "${CLOUDFLARE_ASNS[@]}"
    generate_asn_lists "hetzner" "${HETZNER_ASNS[@]}"
    generate_asn_lists "ovh" "${OVH_ASNS[@]}"
    generate_asn_lists "digitalocean" "${DIGITALOCEAN_ASNS[@]}"
    generate_asn_lists "bunny" "${BUNNY_ASNS[@]}"
    generate_asn_lists "meta" "${META_ASNS[@]}"
    generate_asn_lists "telegram" "${TELEGRAM_ASNS[@]}"
    generate_asn_lists "fastly" "${FASTLY_ASNS[@]}"
    generate_asn_lists "gcore" "${GCORE_ASNS[@]}"

    download "https://d7uri8nf7uskq.cloudfront.net/tools/list-cloudfront-ips" "${FOLDER}"ipv4/cloudfront.json
    parse_json "${FOLDER}"ipv4/cloudfront.json "${FOLDER}"ipv4/cloudfront.txt '(.CLOUDFRONT_GLOBAL_IP_LIST + .CLOUDFRONT_REGIONAL_EDGE_IP_LIST)[]'

    echo >> "${FOLDER}"ipv4/cloudflare.txt
    ensure_eof_nl "${FOLDER}"ipv4/cloudflare.txt "${FOLDER}"ipv6/cloudflare.txt
    cat "${FOLDER}"ipv4/cloudflare.txt "${FOLDER}"ipv6/cloudflare.txt | sort | uniq > "${FOLDER}"dual/cloudflare.txt

    echo >> "${FOLDER}"ipv4/discord-voice.txt
    ensure_eof_nl "${FOLDER}"ipv4/discord-voice.txt "${FOLDER}"ipv6/discord-voice.txt
    cat "${FOLDER}"ipv4/discord-voice.txt "${FOLDER}"ipv6/discord-voice.txt | sort | uniq > "${FOLDER}"dual/discord-voice.txt

    local file
    find "${FOLDER}" -type f -name "*.yaml" | while IFS= read -r file; do
        echo "Processing YAML: $file"
        local mrs_file=${file%.*}.mrs
        yaml_sort_by_alphabet "$file" "$file" "payload"
        mrs_ipcidr "${file}" "${mrs_file}"
    done

    find "${FOLDER}" -type f -name "*.txt" | while IFS= read -r file; do
        echo "Processing: $file"
        local tmp_file="${file%.*}.tmp"
        local yaml_file="${file%.*}.yaml"
        local mrs_file="${file%.*}.mrs"
        cleanup "${file}" "${tmp_file}"
        yaml "${tmp_file}" "${yaml_file}"
        yaml_sort_by_alphabet "$yaml_file" "$yaml_file" "payload"
        mrs_ipcidr "${yaml_file}" "${mrs_file}"
    done

    find "${FOLDER}" -type f -name "*.txt" -exec rm -f {} +
    find "${FOLDER}" -type f -name "*.tmp" -exec rm -f {} +
    #find "${FOLDER}" -type f -name "*.yaml" -exec rm -f {} +
    find "${FOLDER}" -type f -name "*.json" -exec rm -f {} +
}

main
