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
    download "https://iplist.opencck.org/?format=text&data=domains&site=jetbrains.com" ${FOLDER}jet-brains-com.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=jetbrains%40cdn" ${FOLDER}jet-brains-cdn.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=jetbrains%40grazie.ai" ${FOLDER}jet-brains-grazieai.txt

    download "https://iplist.opencck.org/?format=text&data=domains&site=netflix.com" ${FOLDER}netflix.txt
	download "https://iplist.opencck.org/?format=text&data=domains&site=hdrezka.ag" ${FOLDER}hdrezka.txt
	download "https://iplist.opencck.org/?format=text&data=domains&site=lostfilm.tv" ${FOLDER}lostfilm.txt

    download "https://iplist.opencck.org/?format=text&data=domains&site=medium.com" ${FOLDER}medium.txt

	download "https://iplist.opencck.org/?format=text&data=domains&site=chatgpt.com" ${FOLDER}chatgpt.txt
	download "https://iplist.opencck.org/?format=text&data=domains&site=copilot" ${FOLDER}copilot.txt

    download "https://iplist.opencck.org/?format=text&data=domains&site=x.com" ${FOLDER}x-com.txt
    download "https://iplist.opencck.org/?format=text&data=domains&site=facebook.com" ${FOLDER}meta.txt

	cat ${FOLDER}jet-brains-com.txt ${FOLDER}jet-brains-cdn.txt ${FOLDER}jet-brains-grazieai.txt | sort | uniq > ${FOLDER}jet-brains.txt

	cat ${MANUAL_FOLDER}manual-service-hetzner >> ${FOLDER}hetzner.txt
    cat ${MANUAL_FOLDER}manual-service-ovh >> ${FOLDER}ovh.txt
	cat ${MANUAL_FOLDER}manual-service-cloudflare >> ${FOLDER}cloudflare.txt
    cat ${MANUAL_FOLDER}manual-service-discord >> ${FOLDER}discord.txt
	cat ${MANUAL_FOLDER}manual-service-telegram >> ${FOLDER}telegram.txt

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