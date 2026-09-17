#!/usr/bin/env python3
"""Generate bypass/block domain rulesets without the legacy shell orchestrator."""

from __future__ import annotations

from pathlib import Path

from scripts.download_file import download_file
from scripts.external_tools import run_mihomo
from scripts.file_operations import (
    clean_lines,
    exclude_lines,
    lines_to_yaml,
    merge_unique,
    remove_files,
    sort_yaml_section,
)


ROOT = Path(__file__).resolve().parent
FOLDER = ROOT / "block"
YAML_FOLDER = FOLDER / "yaml"
NO_RUSSIA_HOSTS_EXCLUSION_FILE = ROOT / "manual/block/no-russia-hosts-exclusion"

SOURCES = (
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-ecommerce-ru.yaml", "category-ecommerce-ru.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-cdn-!cn.yaml", "category-cdn.yaml"),
    ("https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Categories/geoblock.lst", "itdog-geoblock.txt"),
    ("https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Russia/inside-raw.lst", "itdog-russia-inside.txt"),
    ("https://raw.githubusercontent.com/GubernievS/AntiZapret-VPN/refs/heads/main/setup/root/antizapret/download/include-hosts.txt", "guberniev-include.txt"),
    ("https://community.antifilter.download/list/domains.lst", "antifilter-community.txt"),
    ("https://raw.githubusercontent.com/dartraiden/no-russia-hosts/refs/heads/master/hosts.txt", "no-russia-hosts.txt"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-gov-ru.yaml", "category-gov-ru.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-dev.yaml", "category-dev.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-anticensorship.yaml", "category-anticensorship.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-speedtest.yaml", "category-speedtest.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-remote-control.yaml", "category-remote-control.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-password-management.yaml", "category-password-management.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-ip-geo-detect.yaml", "category-ip-geo-detect.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/tld-ru.yaml", "category-tldr-ru.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-bank-ru.yaml", "category-bank-ru.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-retail-ru.yaml", "category-retail-ru.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-ai-!cn.yaml", "category-ai.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/mailru.list", "mailru.txt"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/kaspersky.list", "kaspersky.txt"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/drweb.list", "drweb.txt"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/yandex.list", "yandex.txt"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-container.yaml", "category-container.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-ru.list", "categ-ru.txt"),
)


def main() -> None:
    FOLDER.mkdir(parents=True, exist_ok=True)
    YAML_FOLDER.mkdir(parents=True, exist_ok=True)
    remove_files(FOLDER, ("*.txt", "*.tmp", "*.yaml"))
    remove_files(YAML_FOLDER, ("*.yaml",))

    for url, filename in SOURCES:
        download_file(url, FOLDER / filename)

    no_russia_hosts = FOLDER / "no-russia-hosts.txt"
    exclude_lines(no_russia_hosts, NO_RUSSIA_HOSTS_EXCLUSION_FILE, no_russia_hosts)

    category_parts = tuple(
        FOLDER / name
        for name in ("mailru.txt", "kaspersky.txt", "drweb.txt", "categ-ru.txt")
    )
    merge_unique(category_parts, FOLDER / "category-ru.txt")
    for path in category_parts:
        path.unlink()

    guberniev = FOLDER / "guberniev-include.txt"
    merge_unique((guberniev, FOLDER / "itdog-russia-inside.txt"), FOLDER / "just-domains.txt")
    guberniev.unlink()

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
        run_mihomo("domain", yaml_file, text_file.with_suffix(".mrs"))

    for yaml_file in FOLDER.glob("*.yaml"):
        yaml_file.replace(YAML_FOLDER / yaml_file.name)
    remove_files(FOLDER, ("*.txt", "*.tmp"))


if __name__ == "__main__":
    main()
