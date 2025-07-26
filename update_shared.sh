#!/bin/bash

download() {
    local uri="$1"
    local output_path="$2"
    local code
    curl -sL "${uri}" -o "${output_path}"
    code=$?
    if [ "$code" -ne 0 ]; then
        echo "Curl failed with exit code $code"
    fi
}

cleanup() {
    local input_file="$1"
    local output_file="$2"
    local tmp_file=$(mktemp)
    grep -v -E '^\s*#|^\s*$' "$input_file" > "$tmp_file"
    mv "$tmp_file" "$output_file"
}

yaml() {
    local input_file="$1"
    local output_file="$2"
    echo "payload:" > "${output_file}"
    cat "${input_file}" | sed "s/.*/  - '&'/" >> "$output_file"
}

mrs_domain() {
    local input_file="$1"
    local output_file="$2"
    ./mihomo convert-ruleset domain yaml "${input_file}" "${output_file}"
}

mrs_ipcidr() {
    local input_file="$1"
    local output_file="$2"
    ./mihomo convert-ruleset ipcidr yaml "${input_file}" ${output_file}
}

yaml_subdomains() {
    local input_file="$1"
    local output_file="$2"
    echo "payload:" > "${output_file}"
    cat "$input_file" | sed "s/^\*\.//; s/.*/  - '+.&'/" >> "$output_file"
}

parse_json() {
    local file="$1"
    local output_file="$2"
    cat "$file" | jq -r '.[] | .[]' > "$output_file"
}

split_subnets() {
    local input_file ipv4_file ipv6_file
    input_file="$1"
    ipv4_file="$2"
    ipv6_file="$3"
    grep -E '\b([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}\b' $input_file > $ipv4_file
    grep -Ev '\b([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]{1,2}\b' $input_file > $ipv6_file
}