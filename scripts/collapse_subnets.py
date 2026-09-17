#!/usr/bin/env python3
"""Collapse overlapping subnet prefixes in generated text files."""

from __future__ import annotations

import argparse
import ipaddress
from pathlib import Path
import sys


def sort_key(network: ipaddress._BaseNetwork) -> tuple[object, ...]:
    return network.version, network.network_address, network.prefixlen


def collapse_file(file_path: str | Path) -> None:
    path = Path(file_path)
    print(f"Collapsing: {path}")
    prefixes: list[ipaddress._BaseNetwork] = []

    if path.exists():
        for line in path.read_text(encoding="utf-8").splitlines():
            value = line.strip()
            if not value or value.startswith("#"):
                continue
            try:
                # strict=False normalizes prefixes containing host bits instead of rejecting them.
                prefixes.append(ipaddress.ip_network(value, strict=False))
            except ValueError as error:
                print(f"  Warning: failed to parse prefix {value!r}: {error}", file=sys.stderr)

    if not prefixes:
        return

    # collapse_addresses cannot mix address families, because apparently four and six need space.
    ipv4 = ipaddress.collapse_addresses(network for network in prefixes if network.version == 4)
    ipv6 = ipaddress.collapse_addresses(network for network in prefixes if network.version == 6)
    collapsed = sorted((*ipv4, *ipv6), key=sort_key)
    with path.open("w", encoding="utf-8", newline="\n") as output:
        output.writelines(f"{network}\n" for network in collapsed)


def collapse_directory(directory: str | Path) -> None:
    root = Path(directory)
    if not root.is_dir():
        raise NotADirectoryError(f"Not a directory: {root}")
    for file_path in sorted(root.rglob("*.txt")):
        collapse_file(file_path)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("directory", nargs="?", type=Path, default=Path("subnets"))
    args = parser.parse_args()
    collapse_directory(args.directory)


if __name__ == "__main__":
    main()
