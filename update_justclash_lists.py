#!/usr/bin/env python3
"""Generate JustClash ruleset indexes."""

from __future__ import annotations

from pathlib import Path
import re

from scripts.file_operations import write_text


ROOT = Path(__file__).resolve().parent
CDN_BASE_URL = "https://cdn.jsdelivr.net/gh/saltymonkey/mrs-parsed-data@main"
JUSTCLASH_FOLDER = ROOT / "justclash"
RULESETS_FILE = JUSTCLASH_FOLDER / "rulesets.txt"
BLOCK_RULESETS_FILE = JUSTCLASH_FOLDER / "block.rulesets.txt"

RULESET_GROUPS = (
    ("mrs", "block", "domain", "", "", "mrs"),
    ("mrs", "services", "domain", "", "", "mrs"),
    ("mrs", "subnets/ipv4", "ipcidr", "CIDR", "ipcidr", "mrs"),
)

BLOCK_RULESET_GROUPS = (
    ("mrs", "ads", "domain", "", "", "mrs"),
    ("mrs", "nsfw", "domain", "", "", "mrs"),
    ("mrs", "badware", "domain", "", "", "mrs"),
)

WORD_REPLACEMENTS = {
    # Acronyms and technical terms.
    "ai": "AI",
    "api": "API",
    "asn": "ASN",
    "bgp": "BGP",
    "cdn": "CDN",
    "cdn77": "CDN77",
    "cidr": "CIDR",
    "dns": "DNS",
    "gpt": "GPT",
    "ip": "IP",
    "ipv4": "IPv4",
    "ipv6": "IPv6",
    "nsfw": "NSFW",
    "oisd": "OISD",
    "ru": "RU",
    "ads": "ADS",
    "tif": "TIF",
    "tld": "TLD",
    "url": "URL",
    "x5": "X5",

    # Names whose official capitalization is more ambitious than str.capitalize().
    "anydesk": "AnyDesk",
    "artstation": "ArtStation",
    "copilot": "Copilot",
    "digitalocean": "DigitalOcean",
    "drweb": "Dr.Web",
    "dyndns": "DynDNS",
    "ecommerce": "eCommerce",
    "f droid": "F-Droid",
    "github": "GitHub",
    "gitlab": "GitLab",
    "google play": "Google Play",
    "hewlett packard": "Hewlett-Packard",
    "itdog": "ITDog",
    "jsdelivr": "jsDelivr",
    "lgwebos": "LG webOS",
    "linkedin": "LinkedIn",
    "mailru": "Mail.ru",
    "mongodb": "MongoDB",
    "npmjs": "npmjs",
    "openai": "OpenAI",
    "openstreetmap": "OpenStreetMap",
    "openwrt": "OpenWrt",
    "opporealme": "OPPO realme",
    "paypal": "PayPal",
    "rutracker": "RuTracker",
    "samsung": "Samsung",
    "tiktok": "TikTok",
    "vivo": "Vivo",
    "whatsapp": "WhatsApp",
    "winoffice": "WinOffice",
    "xiaomi": "Xiaomi",
    "youtube": "YouTube",

    # Short vendor names which otherwise turn into title-cased soup.
    "russia": "Russia",
    "ibm": "IBM",
    "ovh": "OVH",
    "qt": "QT",
    "tldr": "TLDR",
    "amd": "AMD",
    "ea": "EA",
    "hp": "HP",
}


def readable_name(file_stem: str) -> str:
    value = file_stem[:1].upper() + file_stem[1:]
    value = value.replace("-", " ")
    for word, replacement in WORD_REPLACEMENTS.items():
        value = re.sub(rf"\b{re.escape(word)}\b", replacement, value, flags=re.IGNORECASE)
    return value


def generate_list(
    extension: str,
    directory: str,
    rule_type: str,
    readable_name_addon: str = "",
    filename_addon: str = "",
    output_format: str | None = None,
) -> list[str]:
    lines: list[str] = []
    for file_path in sorted((ROOT / directory).rglob(f"*.{extension}")):
        file_stem = file_path.stem
        display_name = readable_name(file_stem)
        if readable_name_addon:
            display_name = f"{display_name} {readable_name_addon}"
        output_name = f"{file_stem}-{filename_addon}" if filename_addon else file_stem
        relative_path = file_path.relative_to(ROOT).as_posix()
        url = f"{CDN_BASE_URL}/{relative_path}"
        lines.append(
            f"{display_name}|{output_name}|{rule_type}|{output_format or extension}|{url}"
        )
    return lines


def render_groups(groups: tuple[tuple[str, str, str, str, str, str], ...]) -> str:
    lines: list[str] = []
    for group in groups:
        lines.extend(generate_list(*group))
    return "\n".join(lines) + ("\n" if lines else "")


def main() -> None:
    JUSTCLASH_FOLDER.mkdir(parents=True, exist_ok=True)
    write_text(RULESETS_FILE, render_groups(RULESET_GROUPS) + "\n")
    write_text(BLOCK_RULESETS_FILE, render_groups(BLOCK_RULESET_GROUPS))


if __name__ == "__main__":
    main()
