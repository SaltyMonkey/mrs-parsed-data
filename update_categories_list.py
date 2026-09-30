#!/usr/bin/env python3
"""Generate block category domain rulesets without the legacy shell orchestrator."""

from __future__ import annotations

from pathlib import Path

from scripts.download_file import download_source
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
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-games-!cn.yaml", "category-games-!cn.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/category-game-platforms-download.yaml", "category-game-platforms-download.yaml"),
    ("https://iplist.opencck.org/?format=text&data=domains&wildcard=1&site=flibusta.is&site=yummyanime.tv&site=anidub.pro&site=amedia.site&site=anilibria.tv&site=animego.org&site=animevost.org&site=shikimori.one&site=myanimelist.net&site=mangapark.net", "category-anime.txt"),
)

CATEGORY_RU_SOURCES = ("mailru.txt", "kaspersky.txt", "drweb.txt", "categ-ru.txt", "yandex.txt")
JUST_DOMAINS_SOURCES = ("guberniev-include.txt", "itdog-russia-inside.txt")


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

    no_russia_hosts = FOLDER / "no-russia-hosts.txt"
    if no_russia_hosts.name in ready:
        exclude_lines(no_russia_hosts, NO_RUSSIA_HOSTS_EXCLUSION_FILE, no_russia_hosts)

    category_parts = tuple(FOLDER / name for name in CATEGORY_RU_SOURCES)
    if all(path.name in ready for path in category_parts):
        merge_unique(category_parts, FOLDER / "category-ru.txt")
        ready.add("category-ru.txt")
        for path in category_parts:
            path.with_suffix(".mrs").unlink(missing_ok=True)
            (YAML_FOLDER / path.with_suffix(".yaml").name).unlink(missing_ok=True)
    else:
        print("Keeping previous ruleset for category-ru.txt")
    for path in category_parts:
        path.unlink(missing_ok=True)
        ready.discard(path.name)

    just_domains_parts = tuple(FOLDER / name for name in JUST_DOMAINS_SOURCES)
    guberniev = just_domains_parts[0]
    if all(path.name in ready for path in just_domains_parts):
        merge_unique(just_domains_parts, FOLDER / "just-domains.txt")
        ready.add("just-domains.txt")
        guberniev.with_suffix(".mrs").unlink(missing_ok=True)
        (YAML_FOLDER / guberniev.with_suffix(".yaml").name).unlink(missing_ok=True)
    else:
        print("Keeping previous ruleset for just-domains.txt")
    guberniev.unlink(missing_ok=True)
    ready.discard(guberniev.name)

    processed_yaml: set[Path] = set()
    for yaml_file in sorted(FOLDER.glob("*.yaml")):
        if yaml_file.name not in ready:
            continue
        print(f"Processing YAML: {yaml_file}")
        sort_yaml_section(yaml_file, yaml_file)
        run_mihomo("domain", yaml_file, yaml_file.with_suffix(".mrs"))
        processed_yaml.add(yaml_file)

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
