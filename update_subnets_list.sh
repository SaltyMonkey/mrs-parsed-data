#!/bin/bash

FOLDER="subnets/"
YAMLFOLDER="subnets/yaml/"
MANUAL_FOLDER="manual/subnets/ipv4/"

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
    download "https://iplist.opencck.org/?format=text&data=cidr4&site=discord.gg" "${FOLDER}"ipv4/discord-voice.txt
    download "https://iplist.opencck.org/?format=text&data=cidr6&site=discord.gg" "${FOLDER}"ipv6/discord-voice.txt
    download "https://community.antifilter.download/list/community.lst" "${FOLDER}"ipv4/antifilter-community.txt
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geoip/apple.yaml" "${FOLDER}"ipv4/apple.yaml

    #download "https://bgp.tools/table.txt" "${FOLDER}"table.txt "SaltyMonkey - 1570693+SaltyMonkey@users.noreply.github.com"
    #get_cidrs_by_asn "24940" "${FOLDER}"table.txt "${FOLDER}"dual/hetzner.txt
    #get_cidrs_by_asn "16276" "${FOLDER}"table.txt "${FOLDER}"dual/ovh.txt
    #get_cidrs_by_asn "14061" "${FOLDER}"table.txt "${FOLDER}"dual/digitalocean.txt
    #get_cidrs_by_asn "200325" "${FOLDER}"table.txt "${FOLDER}"dual/bunny.txt
    #get_cidrs_by_asn "32934" "${FOLDER}"table.txt "${FOLDER}"dual/meta.txt
    #split_subnets "${FOLDER}"dual/hetzner.txt "${FOLDER}"ipv4/hetzner.txt "${FOLDER}"ipv6/hetzner.txt
    #split_subnets "${FOLDER}"dual/ovh.txt "${FOLDER}"ipv4/ovh.txt "${FOLDER}"ipv6/ovh.txt
    #split_subnets "${FOLDER}"dual/digitalocean.txt "${FOLDER}"ipv4/digitalocean.txt "${FOLDER}"ipv6/digitalocean.txt
    #split_subnets "${FOLDER}"dual/bunny.txt "${FOLDER}"ipv4/bunny.txt "${FOLDER}"ipv6/bunny.txt
    #split_subnets "${FOLDER}"dual/meta.txt "${FOLDER}"ipv4/meta.txt "${FOLDER}"ipv6/meta.txt
    #rm -rf "${FOLDER}"table.txt

    bgpq4 -A -F "%n/%l\n" -4 as60068 > "${FOLDER}"ipv4/datacamp.txt
    bgpq4 -A -F "%n/%l\n" -6 as60068 > "${FOLDER}"ipv6/datacamp.txt
    ensure_eof_nl "${FOLDER}"ipv4/datacamp.txt "${FOLDER}"ipv6/datacamp.txt
    cat "${FOLDER}"ipv4/datacamp.txt "${FOLDER}"ipv6/datacamp.txt | sort | uniq > "${FOLDER}"dual/datacamp.txt

    bgpq4 -A -F "%n/%l\n" -4 as13335 | grep -Fvx '1.1.1.0/24' > "${FOLDER}"ipv4/cloudflare.txt
    bgpq4 -A -F "%n/%l\n" -6 as13335 > "${FOLDER}"ipv6/cloudflare.txt
    ensure_eof_nl "${FOLDER}"ipv4/cloudflare.txt "${FOLDER}"ipv6/cloudflare.txt
    cat "${FOLDER}"ipv4/cloudflare.txt "${FOLDER}"ipv6/cloudflare.txt | sort | uniq > "${FOLDER}"dual/cloudflare.txt

    bgpq4 -A -F "%n/%l\n" -4 as24940 > "${FOLDER}"ipv4/hetzner.txt
    bgpq4 -A -F "%n/%l\n" -6 as24940 > "${FOLDER}"ipv6/hetzner.txt
    ensure_eof_nl "${FOLDER}"ipv4/hetzner.txt "${FOLDER}"ipv6/hetzner.txt
    cat "${FOLDER}"ipv4/hetzner.txt "${FOLDER}"ipv6/hetzner.txt | sort | uniq > "${FOLDER}"dual/hetzner.txt

    bgpq4 -A -F "%n/%l\n" -4 as16276 > "${FOLDER}"ipv4/ovh.txt
    bgpq4 -A -F "%n/%l\n" -6 as16276 > "${FOLDER}"ipv6/ovh.txt
    ensure_eof_nl "${FOLDER}"ipv4/ovh.txt "${FOLDER}"ipv6/ovh.txt
    cat "${FOLDER}"ipv4/ovh.txt "${FOLDER}"ipv6/ovh.txt | sort | uniq > "${FOLDER}"dual/ovh.txt

    bgpq4 -A -F "%n/%l\n" -4 as14061 > "${FOLDER}"ipv4/digitalocean.txt
    bgpq4 -A -F "%n/%l\n" -6 as14061 > "${FOLDER}"ipv6/digitalocean.txt
    ensure_eof_nl "${FOLDER}"ipv4/digitalocean.txt "${FOLDER}"ipv6/digitalocean.txt
    cat "${FOLDER}"ipv4/digitalocean.txt "${FOLDER}"ipv6/digitalocean.txt | sort | uniq > "${FOLDER}"dual/digitalocean.txt

    bgpq4 -A -F "%n/%l\n" -4 as200325 > "${FOLDER}"ipv4/bunny.txt
    bgpq4 -A -F "%n/%l\n" -6 as200325 > "${FOLDER}"ipv6/bunny.txt
    ensure_eof_nl "${FOLDER}"ipv4/bunny.txt "${FOLDER}"ipv6/bunny.txt
    cat "${FOLDER}"ipv4/bunny.txt "${FOLDER}"ipv6/bunny.txt | sort | uniq > "${FOLDER}"dual/bunny.txt

    bgpq4 -A -F "%n/%l\n" -4 as32934 > "${FOLDER}"ipv4/meta.txt
    bgpq4 -A -F "%n/%l\n" -6 as32934 > "${FOLDER}"ipv6/meta.txt
    ensure_eof_nl "${FOLDER}"ipv4/meta.txt "${FOLDER}"ipv6/meta.txt
    cat "${FOLDER}"ipv4/meta.txt "${FOLDER}"ipv6/meta.txt | sort | uniq > "${FOLDER}"dual/meta.txt

    download "https://core.telegram.org/resources/cidr.txt" "${FOLDER}"dual/telegram.txt
    split_subnets "${FOLDER}"dual/telegram.txt "${FOLDER}"ipv4/telegram.txt "${FOLDER}"ipv6/telegram.txt

    download "https://d7uri8nf7uskq.cloudfront.net/tools/list-cloudfront-ips" "${FOLDER}"ipv4/cloudfront.json
    parse_json "${FOLDER}"ipv4/cloudfront.json "${FOLDER}"ipv4/cloudfront.txt '(.CLOUDFRONT_GLOBAL_IP_LIST + .CLOUDFRONT_REGIONAL_EDGE_IP_LIST)[]'

    download "https://api.fastly.com/public-ip-list" "${FOLDER}"dual/fastly.json
    parse_json "${FOLDER}"dual/fastly.json "${FOLDER}"ipv4/fastly.txt '.addresses[]'
    parse_json "${FOLDER}"dual/fastly.json "${FOLDER}"ipv6/fastly.txt '.ipv6_addresses[]'
    parse_json "${FOLDER}"dual/fastly.json "${FOLDER}"dual/fastly.txt '(.addresses + .ipv6_addresses)[]'

    download "https://api.gcore.com/cdn/public-net-list" "${FOLDER}"dual/gcore.json
    parse_json "${FOLDER}"dual/gcore.json "${FOLDER}"ipv4/gcore.txt '.addresses[]'
    parse_json "${FOLDER}"dual/gcore.json "${FOLDER}"ipv6/gcore.txt '.addresses_v6[]'
    parse_json "${FOLDER}"dual/gcore.json "${FOLDER}"dual/gcore.txt '(.addresses + .addresses_v6)[]'

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