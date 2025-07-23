#!/bin/bash
GITHUBLINK="https://raw.githubusercontent.com/SaltyMonkey/mrs-parsed-data/refs/heads/main"

rm -f ./README.md

generate_markdown_list() {
    local ext="$1"
    local dir="$2"
    local heading="$3"

    echo "## $heading"

    if find "$dir" -type f -name "*.$ext" | grep -q .; then
        find "$dir" -type f -name "*.$ext" | sort | while read -r file; do
            local file_name
            file_name=$(basename "$file")
            local file_path=${file#./}
            echo "- [$file_name]($GITHUBLINK/$file_path)"
        done
    else
        echo "_No files found._"
    fi

    echo
}

cat <<EOF >> ./README.md

## Services

$(generate_markdown_list "mrs" ./services "MRS")
$(generate_markdown_list "yaml" ./services "YAML")

## ADS

$(generate_markdown_list "mrs" ./ads "MRS")
$(generate_markdown_list "yaml" ./ads "YAML")

## Badware

$(generate_markdown_list "mrs" ./badware "MRS")
$(generate_markdown_list "yaml" ./badware "YAML")

## Bypass

$(generate_markdown_list "mrs" ./bypass "MRS")
$(generate_markdown_list "yaml" ./bypass "YAML")

## Subnets

$(generate_markdown_list "mrs" ./subnets/dual "Combined MRS")

$(generate_markdown_list "mrs" ./subnets/ipv4 "IPv4 MRS")

$(generate_markdown_list "mrs" ./subnets/ipv6 "IPv6 MRS")

## Credits:

- [MetaCubeX](https://github.com/MetaCubeX/meta-rules-dat) for meta-rules-dat repository
- [Rekryt](https://github.com/rekryt/iplist) for https://iplist.opencck.org and hard work with updates
- [ITDog](https://github.com/itdoginfo) and community for Russia Inside list
- [GubernievS](https://github.com/GubernievS/AntiZapret-VPN/blob/main/setup/root/antizapret/download/include-hosts.txt) for include-hosts list with additional domains for bypass
- [Hagezi](https://github.com/hagezi/dns-blocklists) for ADS/BAdware lists
- [OISD.nl Team](https://oisd.nl/) For ADS/NSFW lists
- [Antifilter Community](https://community.antifilter.download/) for IP/Domain lists

EOF