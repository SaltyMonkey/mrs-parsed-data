#!/usr/bin/env python3
"""Generate subnet rulesets without the legacy shell orchestrator."""

from __future__ import annotations

import json
from pathlib import Path

from scripts.collapse_subnets import collapse_file
from scripts.download_file import download_source
from scripts.external_tools import run_bgpq4, run_mihomo
from scripts.file_operations import (
    append_lines,
    clean_lines,
    ensure_eof_newline,
    lines_to_yaml,
    merge_unique,
    remove_files,
    sort_unique_lines,
    sort_yaml_section,
    yaml_payload,
)


ROOT = Path(__file__).resolve().parent
FOLDER = ROOT / "subnets"
CLOUDFRONT_FEED = "cloudfront.json"

ASN_GROUPS = {
    "contabo": (51167, 141995),
    "akamai": (20940, 63949),
    "apple": (714, 6185),
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
    "meta": (32934, 63293, 54115, 149642),
    "telegram": (62041, 62014, 211157, 44907, 59930),
    "fastly": (54113,),
    "gcore": (199524, 202422),
}

TELEGRAM_EXTRA_IPV4_SUBNETS = ("5.28.192.0/18",)

# from itdoginfo/allow-domains
# https://support.google.com/a/answer/1279090
GOOGLE_MEET_V4 = (
    "74.125.247.128/32",
    "74.125.250.0/24",
    "142.250.82.0/24",
)
GOOGLE_MEET_V6 = (
    "2001:4860:4864:4:8000::/128",
    "2001:4860:4864:5::/64",
    "2001:4860:4864:6::/64",
)

SOURCES = (
    ("https://iplist.opencck.org/?format=text&data=cidr4&site=discord.gg&site=discord.media", "ipv4/discord-voice.txt"),
    ("https://iplist.opencck.org/?format=text&data=cidr6&site=discord.gg&site=discord.media", "ipv6/discord-voice.txt"),
    ("https://community.antifilter.download/list/community.lst", "ipv4/antifilter-community.txt"),
    ("https://ip-ranges.amazonaws.com/ip-ranges.json", CLOUDFRONT_FEED),
)


def generate_asn_lists(name: str, asns: tuple[int, ...]) -> None:
    ipv4_file = FOLDER / "ipv4" / f"{name}.txt"
    ipv6_file = FOLDER / "ipv6" / f"{name}.txt"
    run_bgpq4("-4", ipv4_file, [str(asn) for asn in asns])
    run_bgpq4("-6", ipv6_file, [str(asn) for asn in asns])
    merge_unique((ipv4_file, ipv6_file), FOLDER / "dual" / f"{name}.txt")


def parse_cloudfront_feed(source: Path, ipv4_file: Path, ipv6_file: Path) -> None:
    feed = json.loads(source.read_text(encoding="utf-8"))
    ipv4_prefixes = [
        entry["ip_prefix"] for entry in feed["prefixes"] if entry["service"] == "CLOUDFRONT"
    ]
    ipv6_prefixes = [
        entry["ipv6_prefix"] for entry in feed["ipv6_prefixes"] if entry["service"] == "CLOUDFRONT"
    ]

    for path, prefixes in ((ipv4_file, ipv4_prefixes), (ipv6_file, ipv6_prefixes)):
        with path.open("w", encoding="utf-8", newline="\n") as output:
            output.writelines(prefix + "\n" for prefix in prefixes)


def main() -> None:
    for family in ("ipv4", "ipv6", "dual"):
        family_folder = FOLDER / family
        family_folder.mkdir(parents=True, exist_ok=True)
        (family_folder / "yaml").mkdir(parents=True, exist_ok=True)
    ready: set[Path] = set()
    for url, filename in SOURCES:
        destination = FOLDER / filename
        if download_source(url, destination):
            ready.add(destination)
        else:
            print(f"Keeping previous ruleset for {filename}")

    for name, asns in ASN_GROUPS.items():
        generate_asn_lists(name, asns)
        ready.update(FOLDER / family / f"{name}.txt" for family in ("ipv4", "ipv6", "dual"))

    telegram_ipv4 = FOLDER / "ipv4/telegram.txt"
    telegram_ipv6 = FOLDER / "ipv6/telegram.txt"
    append_lines(telegram_ipv4, TELEGRAM_EXTRA_IPV4_SUBNETS)
    ensure_eof_newline((telegram_ipv4, telegram_ipv6))
    merge_unique((telegram_ipv4, telegram_ipv6), FOLDER / "dual/telegram.txt")

    cloudfront_feed = FOLDER / CLOUDFRONT_FEED
    if cloudfront_feed in ready:
        cloudfront_ipv4 = FOLDER / "ipv4/cloudfront.txt"
        cloudfront_ipv6 = FOLDER / "ipv6/cloudfront.txt"
        parse_cloudfront_feed(cloudfront_feed, cloudfront_ipv4, cloudfront_ipv6)
        ready.update((cloudfront_ipv4, cloudfront_ipv6))

    for family, prefixes in (("ipv4", GOOGLE_MEET_V4), ("ipv6", GOOGLE_MEET_V6)):
        subnet_file = FOLDER / family / "google-meet.txt"
        with subnet_file.open("w", encoding="utf-8", newline="\n") as output:
            output.write("\n".join(prefixes) + "\n")
        ready.add(subnet_file)

    for name in ("cloudflare", "discord-voice", "cloudfront", "google-meet"):
        ipv4_file = FOLDER / "ipv4" / f"{name}.txt"
        ipv6_file = FOLDER / "ipv6" / f"{name}.txt"
        if not (ipv4_file in ready and ipv6_file in ready):
            print(f"Keeping previous ruleset for dual/{name}.txt")
            continue
        ensure_eof_newline((ipv4_file, ipv6_file))
        dual_file = FOLDER / "dual" / f"{name}.txt"
        merge_unique((ipv4_file, ipv6_file), dual_file)
        ready.add(dual_file)

    for text_file in sorted(path for path in ready if path.suffix == ".txt"):
        collapse_file(text_file)

    for yaml_file in sorted(path for path in ready if path.suffix == ".yaml"):
        print(f"Processing YAML: {yaml_file}")
        output_folder = yaml_file.parent.parent
        sort_yaml_section(yaml_file, yaml_file)
        yaml_payload(yaml_file, output_folder / f"{yaml_file.stem}.list")
        run_mihomo("ipcidr", yaml_file, output_folder / f"{yaml_file.stem}.mrs")

    for text_file in sorted(path for path in ready if path.suffix == ".txt"):
        print(f"Processing: {text_file}")
        list_file = text_file.with_suffix(".list")
        yaml_file = text_file.parent / "yaml" / f"{text_file.stem}.yaml"
        clean_lines(text_file, list_file)
        sort_unique_lines(list_file, list_file)
        lines_to_yaml(list_file, yaml_file)
        mrs_file = text_file.with_suffix(".mrs")
        if list_file.stat().st_size:
            run_mihomo("ipcidr", yaml_file, mrs_file)
        else:
            mrs_file.unlink(missing_ok=True)

    remove_files(FOLDER, ("*.txt", "*.tmp", "*.json"), recursive=True)


if __name__ == "__main__":
    main()
