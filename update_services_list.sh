#!/bin/bash

FOLDER="services/"
YAMLFOLDER="services/yaml/"
MANUAL_FOLDER="manual/services/"
All_SERVICES_FILENAME="all_services.lst";

source ./update_shared.sh

mkdir -p "${FOLDER}"
mkdir -p "${YAMLFOLDER}"

find "${FOLDER}" -type f -name "*.txt" -exec rm -f {} +
find "${FOLDER}" -type f -name "*.yaml" -exec rm -f {} +
rm -r "${FOLDER}${All_SERVICES_FILENAME}"

main() {
    download "https://iplist.opencck.org/?format=text&data=domains&site=jetbrains.com&wildcard=1" "${FOLDER}"jet-brains-com.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=jetbrains%40cdn&wildcard=1" "${FOLDER}"jet-brains-cdn.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=jetbrains%40grazie.ai&wildcard=1" "${FOLDER}"jet-brains-grazieai.txt
    download "https://beta.iplist.opencck.org/?format=text&data=domains&site=google%40google-gemini" "${FOLDER}"gemini.txt
    download "https://beta.iplist.opencck.org/?format=text&data=domains&site=google%40notebooklm" "${FOLDER}"notebooklm.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=netflix.com&wildcard=1" "${FOLDER}"netflix.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=hdrezka.ag&wildcard=1" "${FOLDER}"hdrezka.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=lostfilm.tv&wildcard=1" "${FOLDER}"lostfilm.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=kinozal.tv&wildcard=1" "${FOLDER}"kinozal.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=medium.com&wildcard=1" "${FOLDER}"medium.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=linkedin.com&wildcard=1" "${FOLDER}"linkedin.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=chatgpt.com&wildcard=1" "${FOLDER}"chatgpt.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=copilot" "${FOLDER}"copilot.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=grok.com&wildcard=1" "${FOLDER}"grok.com.txt
    download "https://iplist.opencck.org/?format=text&data=domains&wildcard=1&site=claude.ai" "${FOLDER}"claudeai.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=x.com&wildcard=1" "${FOLDER}"x.com.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=facebook.com&wildcard=1" "${FOLDER}"meta.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=instagram.com&wildcard=1" "${FOLDER}"instagram.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=youtube.com&wildcard=1" "${FOLDER}"youtube.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=spotify.com&wildcard=1" "${FOLDER}"spotify.txt
    download "https://iplist.opencck.org/?format=text&data=domains&wildcard=1&site=deepl.com" "${FOLDER}"deepl.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=discord.com&site=discord.gg&site=discord.media&wildcard=1" "${FOLDER}"discord.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=rutracker.org&wildcard=1" "${FOLDER}"rutracker.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=nnmclub.to&wildcard=1" "${FOLDER}"nnmclub.txt
    download "https://iplist.opencck.org/?format=text&data=domains&wildcard=1&site=doramy.club" "${FOLDER}"doramyclub.txt
    download "https://iplist.opencck.org/?format=text&data=domains&wildcard=1&site=daramalive.life" "${FOLDER}"daramalivelife.txt
    download "https://iplist.opencck.org/?format=text&data=domains&wildcard=1&site=kino.pub" "${FOLDER}"kinopub.txt
    download "https://beta.iplist.opencck.org/?format=text&data=domains&wildcard=1&site=anydesk.com" "${FOLDER}"anydesk.txt

    cat "${FOLDER}"jet-brains-com.txt "${FOLDER}"jet-brains-cdn.txt "${FOLDER}"jet-brains-grazieai.txt | sort | uniq > "${FOLDER}"jet-brains.txt
    cat "${MANUAL_FOLDER}"manual-service-hetzner >> "${FOLDER}"hetzner.txt
    cat "${MANUAL_FOLDER}"manual-service-ovh >> "${FOLDER}"ovh.txt
    cat "${MANUAL_FOLDER}"manual-service-cloudflare >> "${FOLDER}"cloudflare.txt
    cat "${MANUAL_FOLDER}"manual-service-telegram >> "${FOLDER}"telegram.txt
    cat "${MANUAL_FOLDER}"manual-service-nix-distros >> "${FOLDER}"nix.txt
    cat "${MANUAL_FOLDER}"manual-service-atlassian >> "${FOLDER}"atlassian.txt
    cat "${MANUAL_FOLDER}"manual-service-docker >> "${FOLDER}"docker.txt
    cat "${MANUAL_FOLDER}"manual-service-amazon >> "${FOLDER}"amazon.txt
    cat "${MANUAL_FOLDER}"manual-service-tuya >> "${FOLDER}"tuya.txt
    cat "${MANUAL_FOLDER}"manual-service-twitch-fix >> "${FOLDER}"twitch-fix.txt

    local file
    find "${FOLDER}" -type f -name "*.txt" | while IFS= read -r file; do
        echo "Processing: $file"

        cat "$file" >> "${FOLDER}${All_SERVICES_FILENAME}"
        echo >> "${FOLDER}${All_SERVICES_FILENAME}"

        local yaml_file="${file%.*}.yaml"
        local rms_file="${file%.*}.rms"
        yaml_subdomains "${file}" "${yaml_file}"
        mrs_domain "${yaml_file}" "${rms_file}"
    done

    cleanup "${FOLDER}${All_SERVICES_FILENAME}" "${FOLDER}${All_SERVICES_FILENAME}"

    mv "${FOLDER}"*.yaml "${YAMLFOLDER}"
    find "${FOLDER}" -type f -name "*.txt" -exec rm -f {} +
    #find ${FOLDER} -type f -name "*.yaml" -exec rm -f {} +

}

main