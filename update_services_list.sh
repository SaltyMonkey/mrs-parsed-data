#!/bin/bash

FOLDER="services/"
MANUAL_FOLDER="manual/"

download() {
    local uri="$1"
    local output_path="$2"
    local code
    curl "${uri}" -o "${output_path}"
    code=$?
    if [ $code -ne 0 ]; then
        echo "Curl failed with exit code $code"
    fi
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

find ${FOLDER} -type f -name "*.txt" -exec rm -f {} +
find ${FOLDER} -type f -name "*.yaml" -exec rm -f {} +

main() {
    download "https://iplist.opencck.org/?format=text&data=domains&site=jetbrains.com&wildcard=1" ${FOLDER}jet-brains-com.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=jetbrains%40cdn&wildcard=1" ${FOLDER}jet-brains-cdn.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=jetbrains%40grazie.ai&wildcard=1" ${FOLDER}jet-brains-grazieai.txt
    download "https://beta.iplist.opencck.org/?format=text&data=domains&site=google%40google-gemini" ${FOLDER}gemini.txt
    download "https://beta.iplist.opencck.org/?format=text&data=domains&site=google%40notebooklm" ${FOLDER}notebooklm.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=netflix.com&wildcard=1" ${FOLDER}netflix.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=hdrezka.ag&wildcard=1" ${FOLDER}hdrezka.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=lostfilm.tv&wildcard=1" ${FOLDER}lostfilm.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=kinozal.tv&wildcard=1" ${FOLDER}kinozal.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=medium.com&wildcard=1" ${FOLDER}medium.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=linkedin.com&wildcard=1" ${FOLDER}linkedin.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=chatgpt.com&wildcard=1" ${FOLDER}chatgpt.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=copilot" ${FOLDER}copilot.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=grok.com&wildcard=1" ${FOLDER}grok.com.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=x.com&wildcard=1" ${FOLDER}x-com.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=facebook.com&wildcard=1" ${FOLDER}meta.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=instagram.com&wildcard=1" ${FOLDER}instagram.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=youtube.com&wildcard=1" ${FOLDER}youtube.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=spotify.com&wildcard=1" ${FOLDER}spotify.txt

    download "https://iplist.opencck.org/?format=text&data=domains&site=discord.com&site=discord.gg&site=discord.media&wildcard=1" ${FOLDER}discord.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=rutracker.org&wildcard=1" ${FOLDER}rutracker.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=nnmclub.to&wildcard=1" ${FOLDER}nnmclub.txt

    cat ${FOLDER}jet-brains-com.txt ${FOLDER}jet-brains-cdn.txt ${FOLDER}jet-brains-grazieai.txt | sort | uniq > ${FOLDER}jet-brains.txt

    cat ${MANUAL_FOLDER}manual-service-hetzner >> ${FOLDER}hetzner.txt
    cat ${MANUAL_FOLDER}manual-service-ovh >> ${FOLDER}ovh.txt
    cat ${MANUAL_FOLDER}manual-service-cloudflare >> ${FOLDER}cloudflare.txt
    cat ${MANUAL_FOLDER}manual-service-telegram >> ${FOLDER}telegram.txt
    cat ${MANUAL_FOLDER}manual-service-nix-distros >> ${FOLDER}nix.txt
    cat ${MANUAL_FOLDER}manual-service-atlassian >> ${FOLDER}atlassian.txt
    cat ${MANUAL_FOLDER}manual-service-docker >> ${FOLDER}docker.txt

    local file
    find ${FOLDER} -type f -name "*.txt" | while IFS= read -r file; do
        echo "Processing: $file"
        local yaml_file="${file%.*}.yaml"
        local rms_file="${file%.*}.rms"
        yaml "${file}" "${yaml_file}"
        mrs "${yaml_file}" "${rms_file}"
    done

    find ${FOLDER} -type f -name "*.txt" -exec rm -f {} +
    find ${FOLDER} -type f -name "*.yaml" -exec rm -f {} +

}

main