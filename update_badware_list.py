#!/usr/bin/env python3
"""Generate badware domain rulesets without involving the legacy shell scripts."""

from __future__ import annotations

from pathlib import Path

from scripts.download_file import download_source
from scripts.external_tools import run_mihomo
from scripts.file_operations import clean_lines, lines_to_yaml, remove_files, sort_yaml_section


ROOT = Path(__file__).resolve().parent
FOLDER = ROOT / "badware"
YAML_FOLDER = FOLDER / "yaml"

SOURCES = (
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.winoffice.txt", "hagezi-spy-winoffice.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.apple.txt", "hagezi-spy-apple.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.xiaomi.txt", "hagezi-spy-xiaomi.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.huawei.txt", "hagezi-spy-huawei.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.lgwebos.txt", "hagezi-spy-lgwebos.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.oppo-realme.txt", "hagezi-spy-opporealme.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.vivo.txt", "hagezi-spy-vivo.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.amazon.txt", "hagezi-spy-amazon.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.samsung.txt", "hagezi-spy-samsung.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/native.tiktok.txt", "hagezi-spy-tiktok.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/dyndns.txt", "hagezi-dyndns.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/hoster.txt", "hagezi-badware-hosters.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/social.txt", "hagezi-social-network.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/fake.txt", "hagezi-fakes-scam-trap.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/tif.txt", "hagezi-tif.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/tif.mini.txt", "hagezi-tif-mini.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/gambling.mini.txt", "hagezi-gambling-mini.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/gambling.medium.txt", "hagezi-gambling-medium.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/urlshortener.txt", "hagezi-url-shorteners.txt"),
    ("https://gitlab.com/hagezi/mirror/-/raw/main/dns-blocklists/wildcard/anti.piracy.txt", "hagezi-antipiracy.txt"),
)


def main() -> None:
    FOLDER.mkdir(parents=True, exist_ok=True)
    YAML_FOLDER.mkdir(parents=True, exist_ok=True)
    remove_files(FOLDER, ("*.txt",))
    ready: set[str] = set()
    for url, filename in SOURCES:
        if download_source(url, FOLDER / filename):
            ready.add(filename)
        else:
            print(f"Keeping previous ruleset for {filename}")

    processed_yaml: set[Path] = set()
    for text_file in sorted(FOLDER.glob("*.txt")):
        if text_file.name not in ready:
            continue
        print(f"Processing: {text_file}")
        temporary_file = text_file.with_suffix(".tmp")
        yaml_file = text_file.with_suffix(".yaml")
        clean_lines(text_file, temporary_file)
        lines_to_yaml(temporary_file, yaml_file, subdomains=True)
        run_mihomo("domain", yaml_file, text_file.with_suffix(".mrs"))
        processed_yaml.add(yaml_file)

    for yaml_file in processed_yaml:
        yaml_file.replace(YAML_FOLDER / yaml_file.name)
    remove_files(FOLDER, ("*.txt", "*.tmp"))


if __name__ == "__main__":
    main()
