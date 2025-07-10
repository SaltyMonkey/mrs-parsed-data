#!/bin/bash
GITHUBLINK="https://github.com/SaltyMonkey/mrs-parsed-data/raw/refs/heads/main"

rm -f ./README.md

SERVICES_MRS=$(find "./services" -type f -name "*.mrs" | while read -r file; do
    file_path=${file#./}
    echo "- [$file_path]($GITHUBLINK/$file_path)"
done)
SERVICES_YAML=$(find "./services" -type f -name "*.yaml" | while read -r file; do
    file_path=${file#./}
    echo "- [$file_path]($GITHUBLINK/$file_path)"
done)
BYPASS_MRS=$(find "./bypass" -type f -name "*.mrs" | while read -r file; do
    file_path=${file#./}
    echo "- [$file_path]($GITHUBLINK/$file_path)"
done)
BYPASS_YAML=$(find "./bypass" -type f -name "*.yaml" | while read -r file; do
    file_path=${file#./}
    echo "- [$file_path]($GITHUBLINK/$file_path)"
done)
ADS_MRS=$(find "./ads" -type f -name "*.mrs" | while read -r file; do
    file_path=${file#./}
    echo "- [$file_path]($GITHUBLINK/$file_path)"
done)
ADS_YAML=$(find "./ads" -type f -name "*.yaml" | while read -r file; do
    file_path=${file#./}
    echo "- [$file_path]($GITHUBLINK/$file_path)"
done)
BADWARE_MRS=$(find "./badware" -type f -name "*.mrs" | while read -r file; do
    file_path=${file#./}
    echo "- [$file_path]($GITHUBLINK/$file_path)"
done)
BADWARE_YAML=$(find "./badware" -type f -name "*.yaml" | while read -r file; do
    file_path=${file#./}
    echo "- [$file_path]($GITHUBLINK/$file_path)"
done)
SUBNETS_MRS=$(find "./subnets" -type f -name "*.mrs" | while read -r file; do
    file_path=${file#./}
    echo "- [$file_path]($GITHUBLINK/$file_path)"
done)

cat <<EOF >> ./README.md
## Services
$SERVICES_MRS
$SERVICES_YAML

## ADS
$ADS_MRS
$ADS_YAML

## Badware
$BADWARE_MRS
$BADWARE_YAML

## Bypass
$BYPASS_MRS
$BYPASS_YAML

## Subnets
$SUBNETS_MRS
EOF