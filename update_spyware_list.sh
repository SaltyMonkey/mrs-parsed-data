#!/bin/bash

FOLDER="spyware/"

download() {
	local uri="$1"
	local output_path="$2"
	local code
	curl -L "${uri}" -o "${output_path}"
	code=$?
	if [ $code -ne 0 ]; then
    	echo "Curl failed with exit code $code"
	fi
}

cleanup() {
	local input_file="$1"
	local output_file="$2"
	grep -v -E '^\s*#|^\s*$' $input_file > $output_file
}

yaml() {
	local input_file="$1"
	local output_file="$2"
	echo "payload:" > "${output_file}"
	cat "${input_file}" | sed "s/.*/  - '+.&'/" >> $output_file
}

mrs() {
	local input_file="$1"
	local output_file="$2"
	./mihomo convert-ruleset domain yaml ${input_file} ${output_file}
}


mkdir -p ${FOLDER}
rm -f ${FOLDER}*.txt 2>/dev/null
rm -f ${FOLDER}*.tmp 2>/dev/null
rm -f ${FOLDER}*.yaml 2>/dev/null

main() {
	download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.winoffice.txt ${FOLDER}hagezi-sw-winoffice.txt
	download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.apple.txt ${FOLDER}hagezi-sw-apple.txt
	download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.xiaomi.txt ${FOLDER}hagezi-sw-xiaomi.txt
	download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.huawei.txt ${FOLDER}hagezi-sw-huawei.txt
	download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.lgwebos.txt ${FOLDER}hagezi-sw-lgwebos.txt
	download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.oppo-realme.txt ${FOLDER}hagezi-sw-oopo-realme.txt
	download https://raw.githubusercontent.com/hagezi/dns-blocklists/refs/heads/main/domains/native.vivo.txt ${FOLDER}hagezi-sw-vivo.txt

	local file
	find ${FOLDER} -type f -name "*.txt" | while IFS= read -r file; do
   	 	echo "Processing: $file"
		local tmp_file=${file%.*}.tmp
		local yaml_file=${file%.*}.yaml
		local rms_file=${file%.*}.rms
		cleanup "${file}" "${tmp_file}"
		yaml "${tmp_file}" "${yaml_file}"
		mrs "${yaml_file}" "${rms_file}"
	done

	rm -f ${FOLDER}*.txt 2>/dev/null
	rm -f ${FOLDER}*.tmp 2>/dev/null
    rm -f ${FOLDER}*.yaml 2>/dev/null
}

main