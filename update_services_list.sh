#!/bin/bash

FOLDER="services/"
YAMLFOLDER="services/yaml/"
MANUAL_FOLDER="manual/services/"

source ./update_shared.sh

mkdir -p "${FOLDER}"
mkdir -p "${YAMLFOLDER}"

find "${FOLDER}" -type f -name "*.txt" -exec rm -f {} +
find "${FOLDER}" -type f -name "*.yaml" -exec rm -f {} +

main() {
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/openstreetmap.yaml" "${FOLDER}"openstreetmap.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/f-droid.yaml" "${FOLDER}"f-droid.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite-lite/tiktok.yaml" "${FOLDER}"tiktok.yaml
    download "https://beta.iplist.opencck.org/?format=text&data=domains&wildcard=1&site=anydesk.com" "${FOLDER}"anydesk.txt
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/kinopub.yaml" "${FOLDER}"kinopub.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/microsoft.yaml" "${FOLDER}"microsoft.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/hdrezka.yaml" "${FOLDER}"hdrezka.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/anthropic.yaml" "${FOLDER}"anthropic.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite-lite/openai.yaml" "${FOLDER}"openai.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/instagram.yaml" "${FOLDER}"instagram.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/spotify.yaml" "${FOLDER}"spotify.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/linkedin.yaml" "${FOLDER}"linkedin.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/x.yaml" "${FOLDER}"x.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/discord.yaml" "${FOLDER}"discord.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/netflix.yaml" "${FOLDER}"netflix.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/telegram.yaml" "${FOLDER}"telegram.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/github.yaml" "${FOLDER}"github.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/github-copilot.yaml" "${FOLDER}"copilot.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/google-play.yaml" "${FOLDER}"google-play.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/google-gemini.yaml" "${FOLDER}"gemini.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/xbox.yaml" "${FOLDER}"xbox.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/archive.yaml" "${FOLDER}"archive.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/alibaba.yaml" "${FOLDER}"alibaba.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/perplexity.yaml" "${FOLDER}"perplexity.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/youtube.yaml" "${FOLDER}"youtube.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/amazon.yaml" "${FOLDER}"amazon.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/apple.yaml" "${FOLDER}"apple.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/mongodb.yaml" "${FOLDER}"mongodb.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/azure.yaml" "${FOLDER}"azure.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/bilibili.yaml" "${FOLDER}"bilibili.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/whatsapp.yaml" "${FOLDER}"whatsapp.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/google-play.yaml" "${FOLDER}"google-play.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/google.yaml" "${FOLDER}"google.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/akamai.yaml" "${FOLDER}"akamai.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/netlify.yaml" "${FOLDER}"netlify.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/twitch.yaml" "${FOLDER}"twitch.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/amd.yaml" "${FOLDER}"amd.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/tailscale.yaml" "${FOLDER}"tailscale.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/ibm.yaml" "${FOLDER}"ibm.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/oracle.yaml" "${FOLDER}"oracle.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/redhat.yaml" "${FOLDER}"redhat.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/intel.yaml" "${FOLDER}"intel.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/jsdelivr.yaml" "${FOLDER}"jsdelivr.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/broadcom.yaml" "${FOLDER}"broadcom.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/qualcomm.yaml" "${FOLDER}"qualcomm.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/kubernetes.yaml" "${FOLDER}"kubernetes.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/cisco.yaml" "${FOLDER}"cisco.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/qt.yaml" "${FOLDER}"qt.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/canon.yaml" "${FOLDER}"canon.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/corel.yaml" "${FOLDER}"corel.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/hp.yaml" "${FOLDER}"hewlett-packard.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/lenovo.yaml" "${FOLDER}"lenovo.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/connectivity-check.yaml" "${FOLDER}"connectivity-check.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/digitalocean.yaml" "${FOLDER}"digitalocean.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/fastly.yaml" "${FOLDER}"fastly.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/openwrt.yaml" "${FOLDER}"openwrt.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/tencent.yaml" "${FOLDER}"tencent.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/vercel.yaml" "${FOLDER}"vercel.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/cloudflare.yaml" "${FOLDER}"cloudflare.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/meta.yaml" "${FOLDER}"meta.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/artstation.yaml" "${FOLDER}"artstation.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/npmjs.yaml" "${FOLDER}"npmjs.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/paypal.yaml" "${FOLDER}"paypal.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/pixiv.yaml" "${FOLDER}"pixiv.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/rutracker.yaml" "${FOLDER}"rutracker.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/hetzner.yaml" "${FOLDER}"hetzner.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/panasonic.yaml" "${FOLDER}"panasonic.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/flibusta.yaml" "${FOLDER}"flibusta.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/nvidia.yaml" "${FOLDER}"nvidia.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/cdn77.yaml" "${FOLDER}"cdn77.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/steam.yaml" "${FOLDER}"steam.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/ea.yaml" "${FOLDER}"ea.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/mega.yaml" "${FOLDER}"mega.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/docker.yaml" "${FOLDER}"docker.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/nintendo.yaml" "${FOLDER}"nintendo.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/mailru.list" "${FOLDER}"mailru.txt
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/kaspersky.list" "${FOLDER}"kaspersky.txt
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/drweb.list" "${FOLDER}"drweb.txt

    cat "${MANUAL_FOLDER}"manual-service-ovh >> "${FOLDER}"ovh.txt
    cat "${MANUAL_FOLDER}"manual-service-nix-distros >> "${FOLDER}"nix.txt
    cat "${MANUAL_FOLDER}"manual-service-atlassian >> "${FOLDER}"atlassian.txt
    cat "${MANUAL_FOLDER}"manual-service-twitch-fix >> "${FOLDER}"twitch-fix.txt
    cat "${MANUAL_FOLDER}"manual-service-bunny >> "${FOLDER}"bunny.txt
    cat "${MANUAL_FOLDER}"manual-service-gcore >> "${FOLDER}"gcore.txt
    cat "${MANUAL_FOLDER}"manual-service-dns-test >> "${FOLDER}"dns-test.txt

    local file

    find "${FOLDER}" -type f -name "*.yaml" | while IFS= read -r file; do
        echo "Processing YAML: $file"
        local mrs_file=${file%.*}.mrs
        yaml_sort_by_alphabet "$file" "$file" "payload"
        mrs_domain "${file}" "${mrs_file}"
    done

    find "${FOLDER}" -type f -name "*.txt" | while IFS= read -r file; do
        echo "Processing: $file"

        local yaml_file="${file%.*}.yaml"
        local mrs_file="${file%.*}.mrs"
        yaml_subdomains "${file}" "${yaml_file}"
        mrs_domain "${yaml_file}" "${mrs_file}"
    done

    mv "${FOLDER}"*.yaml "${YAMLFOLDER}"
    find "${FOLDER}" -type f -name "*.txt" -exec rm -f {} +
    #find ${FOLDER} -type f -name "*.yaml" -exec rm -f {} +

}

main