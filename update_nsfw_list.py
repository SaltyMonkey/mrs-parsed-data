#!/usr/bin/env python3
"""Generate NSFW domain rulesets separately from advertising lists."""

from __future__ import annotations

from pathlib import Path

from scripts.download_file import download_file
from scripts.external_tools import run_mihomo
from scripts.file_operations import clean_lines, lines_to_yaml, remove_files, sort_yaml_section


ROOT = Path(__file__).resolve().parent
FOLDER = ROOT / "nsfw"
YAML_FOLDER = FOLDER / "yaml"

SOURCES = (
    ("https://nsfw-small.oisd.nl/domainswild", "oisd-nsfw-small.txt"),
    ("https://nsfw.oisd.nl/domainswild", "oisd-nsfw.txt"),
    ("https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/nsfw.txt", "hagezi-nsfw.txt")
)


def main() -> None:
    FOLDER.mkdir(parents=True, exist_ok=True)
    YAML_FOLDER.mkdir(parents=True, exist_ok=True)
    remove_files(FOLDER, ("*.txt", "*.tmp", "*.yaml"))
    remove_files(YAML_FOLDER, ("*.yaml",))

    for url, filename in SOURCES:
        download_file(url, FOLDER / filename)

    for text_file in sorted(FOLDER.glob("*.txt")):
        print(f"Processing: {text_file}")
        temporary_file = text_file.with_suffix(".tmp")
        yaml_file = text_file.with_suffix(".yaml")
        clean_lines(text_file, temporary_file)
        lines_to_yaml(temporary_file, yaml_file, subdomains=True)
        run_mihomo("domain", yaml_file, text_file.with_suffix(".mrs"))

    # Keep source YAML together; apparently scattering formats was too peaceful.
    for yaml_file in FOLDER.glob("*.yaml"):
        yaml_file.replace(YAML_FOLDER / yaml_file.name)
    remove_files(FOLDER, ("*.txt", "*.tmp"))


if __name__ == "__main__":
    main()
