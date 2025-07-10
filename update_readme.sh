#!/bin/bash
GITHUBLINK="https://github.com/SaltyMonkey/rms-parsed-data/raw/refs/heads/main"

rm -f ./README.md

SERVICES_rms=$(find "./services" -type f -name "*.rms" | while read -r file; do
    file_name=$(basename "$file")
    file_path=${file#./}
    echo "- [$file_name]($GITHUBLINK/$file_path)"
done)
SERVICES_YAML=$(find "./services" -type f -name "*.yaml" | while read -r file; do
    file_name=$(basename "$file")
    file_path=${file#./}
    echo "- [$file_name]($GITHUBLINK/$file_path)"
done)
BYPASS_rms=$(find "./bypass" -type f -name "*.rms" | while read -r file; do
    file_name=$(basename "$file")
    file_path=${file#./}
    echo "- [$file_name]($GITHUBLINK/$file_path)"
done)
BYPASS_YAML=$(find "./bypass" -type f -name "*.yaml" | while read -r file; do
    file_name=$(basename "$file")
    file_path=${file#./}
    echo "- [$file_name]($GITHUBLINK/$file_path)"
done)
ADS_rms=$(find "./ads" -type f -name "*.rms" | while read -r file; do
    file_name=$(basename "$file")
    file_path=${file#./}
    echo "- [$file_name]($GITHUBLINK/$file_path)"
done)
ADS_YAML=$(find "./ads" -type f -name "*.yaml" | while read -r file; do
    file_name=$(basename "$file")
    file_path=${file#./}
    echo "- [$file_name]($GITHUBLINK/$file_path)"
done)
BADWARE_rms=$(find "./badware" -type f -name "*.rms" | while read -r file; do
    file_name=$(basename "$file")
    file_path=${file#./}
    echo "- [$file_name]($GITHUBLINK/$file_path)"
done)
BADWARE_YAML=$(find "./badware" -type f -name "*.yaml" | while read -r file; do
    file_name=$(basename "$file")
    file_path=${file#./}
    echo "- [$file_name]($GITHUBLINK/$file_path)"
done)
SUBNETS_rms=$(find "./subnets" -type f -name "*.rms" | while read -r file; do
    file_name=$(basename "$file")
    file_path=${file#./}
    echo "- [$file_name]($GITHUBLINK/$file_path)"
done)

cat <<EOF >> ./README.md
## Services
$SERVICES_rms
$SERVICES_YAML

## ADS
$ADS_rms
$ADS_YAML

## Badware
$BADWARE_rms
$BADWARE_YAML

## Bypass
$BYPASS_rms
$BYPASS_YAML

## Subnets
$SUBNETS_rms
EOF