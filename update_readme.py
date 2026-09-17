#!/usr/bin/env python3
"""Regenerate README links for all published rulesets."""

from __future__ import annotations

from pathlib import Path

from scripts.file_operations import write_text


ROOT = Path(__file__).resolve().parent
CDN_BASE_URL = "https://cdn.jsdelivr.net/gh/saltymonkey/mrs-parsed-data"
README_FILE = ROOT / "README.md"

SECTIONS = (
    ("Services", (("mrs", "services", "MRS"), ("yaml", "services", "YAML")), ()),
    ("ADS", (("mrs", "ads", "MRS"), ("yaml", "ads", "YAML")), ()),
    ("Badware", (("mrs", "badware", "MRS"), ("yaml", "badware", "YAML")), ()),
    ("Bypass", (("mrs", "block", "MRS"), ("yaml", "block", "YAML")), ()),
    (
        "Subnets",
        (
            ("mrs", "subnets/dual", "Combined MRS"),
            ("yaml", "subnets/dual", "Combined YAML"),
            ("mrs", "subnets/ipv4", "IPv4 MRS"),
            ("yaml", "subnets/ipv4", "IPv4 YAML"),
            ("mrs", "subnets/ipv6", "IPv6 MRS"),
            ("yaml", "subnets/ipv6", "IPv6 YAML"),
        ),
        (1, 3),
    ),
)

CREDITS = """## Credits:

- [MetaCubeX](https://github.com/MetaCubeX/meta-rules-dat) for meta-rules-dat repository
- [Rekryt](https://github.com/rekryt/iplist) for https://iplist.opencck.org and hard work with updates
- [ITDog](https://github.com/itdoginfo) and community for Russia Inside list
- [GubernievS](https://github.com/GubernievS/AntiZapret-VPN/blob/main/setup/root/antizapret/download/include-hosts.txt) for include-hosts list with additional domains for bypass
- [Hagezi](https://github.com/hagezi/dns-blocklists) for ADS/BAdware lists
- [OISD.nl Team](https://oisd.nl/) For ADS/NSFW lists
- [Antifilter Community](https://community.antifilter.download/) for IP/Domain lists
"""


def generate_markdown_list(extension: str, directory: str, heading: str) -> str:
    lines = [f"### {heading}"]
    files = sorted((ROOT / directory).rglob(f"*.{extension}"))
    if files:
        for file_path in files:
            relative_path = file_path.relative_to(ROOT).as_posix()
            lines.append(f"- [{file_path.name}]({CDN_BASE_URL}/{relative_path})")
    else:
        lines.append("_No files found._")
    return "\n".join(lines)


def render_section(
    title: str,
    groups: tuple[tuple[str, str, str], ...],
    blank_after: tuple[int, ...],
) -> str:
    result = f"## {title}\n\n"
    for index, group in enumerate(groups):
        if index:
            result += "\n\n" if index - 1 in blank_after else "\n"
        result += generate_markdown_list(*group)
    return result


def render_readme() -> str:
    parts: list[str] = []
    for title, groups, blank_after in SECTIONS:
        parts.append(render_section(title, groups, blank_after))
    parts.append(CREDITS.rstrip())
    return "\n" + "\n\n".join(parts) + "\n\n"


def main() -> None:
    write_text(README_FILE, render_readme())


if __name__ == "__main__":
    main()
