#!/usr/bin/env python3
"""Generate advertising domain rulesets without involving the legacy shell scripts."""

from __future__ import annotations

from pathlib import Path

from scripts.download_file import download_file
from scripts.external_tools import run_mihomo
from scripts.file_operations import clean_lines, lines_to_yaml, remove_files, sort_yaml_section


ROOT = Path(__file__).resolve().parent
FOLDER = ROOT / "ads"
YAML_FOLDER = FOLDER / "yaml"

SOURCES = (
    ("https://nsfw-small.oisd.nl/domainswild", "oisd-nsfw-small.txt"),
    ("https://small.oisd.nl/domainswild", "oisd-small.txt"),
    ("https://nsfw.oisd.nl/domainswild", "oisd-nsfw.txt"),
    ("https://big.oisd.nl/domainswild", "oisd-big.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/pro.txt", "hagezi-pro-ads.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/pro.mini.txt", "hagezi-pro-mini-ads.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/pro.plus.mini.txt", "hagezi-pro-plus-mini-ads.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/light.txt", "hagezi-light-ads.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/ultimate.mini.txt", "hagezi-ultimate-mini-ads.txt"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/apple%40ads.yaml", "apple-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/google%40ads.yaml", "google-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/amazon%40ads.yaml", "amazon-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/meta%40ads.yaml", "meta-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/x5%40ads.yaml", "x5-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/x%40ads.yaml", "x-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/ozon%40ads.yaml", "ozon-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/wildberries%40ads.yaml", "wildberries-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/sber%40ads.yaml", "sber-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/yandex%40ads.yaml", "yandex-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/microsoft%40ads.yaml", "microsoft-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-ru%40ads.yaml", "category-ru-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-bank-ru%40ads.yaml", "category-bank-ru-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-ecommerce-ru%40ads.yaml", "category-ecommerce-ru-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/spotify%40ads.yaml", "spotify-ads.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-ads-all.yaml", "category-ads-all.yaml"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/popupads.txt", "hagezi-popups-ads.txt"),
)


def main() -> None:
    FOLDER.mkdir(parents=True, exist_ok=True)
    YAML_FOLDER.mkdir(parents=True, exist_ok=True)
    remove_files(FOLDER, ("*.txt", "*.tmp", "*.yaml"))
    remove_files(YAML_FOLDER, ("*.yaml",))

    for url, filename in SOURCES:
        download_file(url, FOLDER / filename)

    for yaml_file in sorted(FOLDER.glob("*.yaml")):
        print(f"Processing YAML: {yaml_file}")
        sort_yaml_section(yaml_file, yaml_file)
        run_mihomo("domain", yaml_file, yaml_file.with_suffix(".mrs"))

    for text_file in sorted(FOLDER.glob("*.txt")):
        print(f"Processing: {text_file}")
        temporary_file = text_file.with_suffix(".tmp")
        yaml_file = text_file.with_suffix(".yaml")
        clean_lines(text_file, temporary_file)
        lines_to_yaml(temporary_file, yaml_file, subdomains=True)
        sort_yaml_section(yaml_file, yaml_file)
        run_mihomo("domain", yaml_file, text_file.with_suffix(".mrs"))

    for yaml_file in FOLDER.glob("*.yaml"):
        yaml_file.replace(YAML_FOLDER / yaml_file.name)
    remove_files(FOLDER, ("*.txt", "*.tmp"))


if __name__ == "__main__":
    main()
