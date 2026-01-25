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
    download "https://beta.iplist.opencck.org/?format=text&data=domains&site=google%40google-gemini" "${FOLDER}"gemini.txt
    download "https://beta.iplist.opencck.org/?format=text&data=domains&site=google%40notebooklm" "${FOLDER}"notebooklm.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=netflix.com&wildcard=1" "${FOLDER}"netflix.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=hdrezka.ag&wildcard=1" "${FOLDER}"hdrezka.txt
    download "https://iplist.opencck.org/?format=text&data=domains&wildcard=1&site=filmix.fm" "${FOLDER}"filmix.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=lostfilm.tv&wildcard=1" "${FOLDER}"lostfilm.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=kinozal.tv&wildcard=1" "${FOLDER}"kinozal.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=medium.com&wildcard=1" "${FOLDER}"medium.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=linkedin.com&wildcard=1" "${FOLDER}"linkedin.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=chatgpt.com&wildcard=1" "${FOLDER}"chatgpt.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=copilot" "${FOLDER}"copilot.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=grok.com&wildcard=1" "${FOLDER}"grok.txt
    download "https://iplist.opencck.org/?format=text&data=domains&wildcard=1&site=claude.ai" "${FOLDER}"claudeai.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=x.com&wildcard=1" "${FOLDER}"x.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=instagram.com&wildcard=1" "${FOLDER}"instagram.txt
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/spotify.yaml" "${FOLDER}"spotify.yaml
    download "https://iplist.opencck.org/?format=text&data=domains&wildcard=1&site=deepl.com" "${FOLDER}"deepl.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=discord.com&site=discord.gg&site=discord.media&wildcard=1" "${FOLDER}"discord.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=nnmclub.to&wildcard=1" "${FOLDER}"nnmclub.txt
    download "https://iplist.opencck.org/?format=text&data=domains&wildcard=1&site=doramy.club" "${FOLDER}"doramyclub.txt
    download "https://iplist.opencck.org/?format=text&data=domains&wildcard=1&site=daramalive.life" "${FOLDER}"daramalivelife.txt
    download "https://iplist.opencck.org/?format=text&data=domains&wildcard=1&site=kino.pub" "${FOLDER}"kinopub.txt
    download "https://beta.iplist.opencck.org/?format=text&data=domains&wildcard=1&site=anydesk.com" "${FOLDER}"anydesk.txt
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/telegram.yaml" "${FOLDER}"telegram.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/xbox.yaml" "${FOLDER}"xbox.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/archive.yaml" "${FOLDER}"archive.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/alibaba.yaml" "${FOLDER}"alibaba.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/perplexity.yaml" "${FOLDER}"perplexity.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/youtube.yaml" "${FOLDER}"youtube.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/amazon.yaml" "${FOLDER}"amazon.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/apple.yaml" "${FOLDER}"apple.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/mongodb.yaml" "${FOLDER}"mongodb.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/azure.yaml" "${FOLDER}"azure.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/azure.yaml" "${FOLDER}"azure.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/bilibili.yaml" "${FOLDER}"bilibili.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/whatsapp.yaml" "${FOLDER}"whatsapp.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/google-play.yaml" "${FOLDER}"google-play.yaml
    download "https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/google.yaml" "${FOLDER}"google.yaml
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