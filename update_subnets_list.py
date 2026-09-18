#!/usr/bin/env python3
"""Generate subnet rulesets without the legacy shell orchestrator."""

from __future__ import annotations

from pathlib import Path

from scripts.collapse_subnets import collapse_file
from scripts.download_file import download_file
from scripts.external_tools import run_bgpq4, run_mihomo
from scripts.file_operations import (
    append_lines,
    clean_lines,
    ensure_eof_newline,
    json_arrays,
    lines_to_yaml,
    merge_unique,
    remove_files,
    sort_unique_lines,
    sort_yaml_section,
    yaml_payload,
)


ROOT = Path(__file__).resolve().parent
FOLDER = ROOT / "subnets"

ASN_GROUPS = {
    "contabo": (51167, 141995),
    "akamai": (20940, 63949),
    "roblox": (22697,),
    "scaleway": (12876,),
    "scalaxy": (58061,),
    "cdn77": (60068,),
    "datacamp": (212238,),
    "cloudflare": (13335,),
    "hetzner": (24940,),
    "ovh": (16276,),
    "digitalocean": (14061,),
    "bunny": (200325,),
    "meta": (32934,),
    "telegram": (62041, 62014, 211157, 44907, 59930),
    "fastly": (54113,),
    "gcore": (199524, 202422),
}

TELEGRAM_EXTRA_IPV4_SUBNETS = ("5.28.192.0/18",)

SOURCES = (
    ("https://iplist.opencck.org/?format=text&data=cidr4&site=discord.gg", "ipv4/discord-voice.txt"),
    ("https://iplist.opencck.org/?format=text&data=cidr6&site=discord.gg", "ipv6/discord-voice.txt"),
    ("https://community.antifilter.download/list/community.lst", "ipv4/antifilter-community.txt"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geoip/apple.yaml", "ipv4/yaml/apple.yaml"),
    ("https://d7uri8nf7uskq.cloudfront.net/tools/list-cloudfront-ips", "ipv4/cloudfront.json"),
)


def generate_asn_lists(name: str, asns: tuple[int, ...]) -> None:
    ipv4_file = FOLDER / "ipv4" / f"{name}.txt"
    ipv6_file = FOLDER / "ipv6" / f"{name}.txt"
    run_bgpq4("-4", ipv4_file, [str(asn) for asn in asns])
    run_bgpq4("-6", ipv6_file, [str(asn) for asn in asns])
    merge_unique((ipv4_file, ipv6_file), FOLDER / "dual" / f"{name}.txt")


def main() -> None:
    for family in ("ipv4", "ipv6", "dual"):
        family_folder = FOLDER / family
        family_folder.mkdir(parents=True, exist_ok=True)
        (family_folder / "yaml").mkdir(parents=True, exist_ok=True)
    remove_files(FOLDER, ("*.txt", "*.tmp", "*.yaml", "*.json", "*.list"), recursive=True)

    for url, filename in SOURCES:
        download_file(url, FOLDER / filename)

    for name, asns in ASN_GROUPS.items():
        generate_asn_lists(name, asns)

    telegram_ipv4 = FOLDER / "ipv4/telegram.txt"
    telegram_ipv6 = FOLDER / "ipv6/telegram.txt"
    append_lines(telegram_ipv4, TELEGRAM_EXTRA_IPV4_SUBNETS)
    ensure_eof_newline((telegram_ipv4, telegram_ipv6))
    merge_unique((telegram_ipv4, telegram_ipv6), FOLDER / "dual/telegram.txt")

    json_arrays(
        FOLDER / "ipv4/cloudfront.json",
        FOLDER / "ipv4/cloudfront.txt",
        ("CLOUDFRONT_GLOBAL_IP_LIST", "CLOUDFRONT_REGIONAL_EDGE_IP_LIST"),
    )

    for name in ("cloudflare", "discord-voice"):
        ipv4_file = FOLDER / "ipv4" / f"{name}.txt"
        ipv6_file = FOLDER / "ipv6" / f"{name}.txt"
        ensure_eof_newline((ipv4_file, ipv6_file))
        merge_unique((ipv4_file, ipv6_file), FOLDER / "dual" / f"{name}.txt")

    for text_file in FOLDER.rglob("*.txt"):
        collapse_file(text_file)

    for yaml_file in sorted(FOLDER.rglob("*.yaml")):
        print(f"Processing YAML: {yaml_file}")
        output_folder = yaml_file.parent.parent
        sort_yaml_section(yaml_file, yaml_file)
        yaml_payload(yaml_file, output_folder / f"{yaml_file.stem}.list")
        run_mihomo("ipcidr", yaml_file, output_folder / f"{yaml_file.stem}.mrs")

    for text_file in sorted(FOLDER.rglob("*.txt")):
        print(f"Processing: {text_file}")
        list_file = text_file.with_suffix(".list")
        yaml_file = text_file.parent / "yaml" / f"{text_file.stem}.yaml"
        clean_lines(text_file, list_file)
        sort_unique_lines(list_file, list_file)
        lines_to_yaml(list_file, yaml_file)
        run_mihomo("ipcidr", yaml_file, text_file.with_suffix(".mrs"))

    remove_files(FOLDER, ("*.txt", "*.tmp", "*.json"), recursive=True)


if __name__ == "__main__":
    main()
