#!/usr/bin/env python3
"""Small file transformations used by the update scripts."""

from __future__ import annotations

import argparse
import ipaddress
import json
import os
from pathlib import Path
import tempfile
from typing import Iterable, Sequence

import yaml


class IndentedSafeDumper(yaml.SafeDumper):
    # PyYAML prefers indentation-free sequences by default. Humans, mysteriously, do not.
    def increase_indent(self, flow: bool = False, indentless: bool = False):
        return super().increase_indent(flow, indentless=False)


def _write_text(path: str | Path, text: str) -> None:
    output_path = Path(path)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    # Write next to the target and replace it only after the complete content is ready.
    temporary_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            newline="\n",
            dir=output_path.parent,
            prefix=f".{output_path.name}.write.",
            delete=False,
        ) as temporary_file:
            temporary_path = Path(temporary_file.name)
            temporary_file.write(text)
        os.replace(temporary_path, output_path)
    finally:
        if temporary_path is not None:
            temporary_path.unlink(missing_ok=True)


def write_text(path: str | Path, text: str) -> None:
    _write_text(path, text)


# Plain-text helpers shared by several generators.
def ensure_eof_newline(paths: Iterable[str | Path]) -> None:
    for path_value in paths:
        path = Path(path_value)
        content = path.read_bytes()
        if content and not content.endswith(b"\n"):
            path.write_bytes(content + b"\n")


def clean_lines(input_path: str | Path, output_path: str | Path) -> None:
    lines = Path(input_path).read_text(encoding="utf-8").splitlines()
    kept = [line for line in lines if line.strip() and not line.lstrip().startswith("#")]
    _write_text(output_path, "".join(f"{line}\n" for line in kept))


def sort_unique_lines(input_path: str | Path, output_path: str | Path) -> None:
    lines = Path(input_path).read_text(encoding="utf-8").splitlines()
    _write_text(output_path, "".join(f"{line}\n" for line in sorted(set(lines))))


def merge_unique(input_paths: Iterable[str | Path], output_path: str | Path) -> None:
    lines: set[str] = set()
    for input_path in input_paths:
        lines.update(Path(input_path).read_text(encoding="utf-8").splitlines())
    _write_text(output_path, "".join(f"{line}\n" for line in sorted(lines)))


def append_file(input_path: str | Path, output_path: str | Path) -> None:
    source = Path(input_path).read_bytes()
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open("ab") as output:
        output.write(source)


def append_lines(output_path: str | Path, lines: Iterable[str]) -> None:
    destination = Path(output_path)
    destination.parent.mkdir(parents=True, exist_ok=True)
    with destination.open("a", encoding="utf-8", newline="\n") as output:
        for line in lines:
            output.write(f"{line}\n")


def remove_files(directory: str | Path, patterns: Iterable[str], recursive: bool = False) -> None:
    root = Path(directory)
    for pattern in patterns:
        matches = root.rglob(pattern) if recursive else root.glob(pattern)
        for path in matches:
            if path.is_file():
                path.unlink()


# YAML helpers keep all parsing and serialization in one place.
def _remove_prefix(value: str, prefix: str) -> str:
    return value[len(prefix) :] if value.startswith(prefix) else value


def _load_yaml_mapping(input_path: str | Path) -> dict:
    data = yaml.safe_load(Path(input_path).read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise TypeError(f"YAML document in {input_path} must be a mapping")
    return data


def _dump_yaml(output_path: str | Path, data: dict) -> None:
    content = yaml.dump(
        data,
        Dumper=IndentedSafeDumper,
        allow_unicode=True,
        default_flow_style=False,
        sort_keys=False,
    )
    _write_text(output_path, content)


def lines_to_yaml(
    input_path: str | Path,
    output_path: str | Path,
    subdomains: bool = False,
) -> None:
    values = sorted(set(Path(input_path).read_text(encoding="utf-8").splitlines()))
    if subdomains:
        # Mihomo expects one canonical "+." prefix, regardless of the source notation.
        values = [f"+.{_remove_prefix(_remove_prefix(value, '*.'), '+.')}" for value in values]
    _dump_yaml(output_path, {"payload": values})


def sort_yaml_section(
    input_path: str | Path,
    output_path: str | Path,
    section: str = "payload",
) -> None:
    data = _load_yaml_mapping(input_path)
    values = data.get(section)
    if not isinstance(values, list):
        raise TypeError(f"YAML section {section!r} in {input_path} must be a list")
    if not all(isinstance(value, str) for value in values):
        raise TypeError(f"YAML section {section!r} in {input_path} must contain only strings")
    data[section] = sorted(values)
    _dump_yaml(output_path, data)


def yaml_payload(input_path: str | Path, output_path: str | Path) -> None:
    data = _load_yaml_mapping(input_path)
    payload = data.get("payload")
    if not isinstance(payload, list) or not all(isinstance(value, str) for value in payload):
        raise TypeError(f"YAML payload in {input_path} must be a list of strings")
    values = [value for value in payload if value and not value.startswith("#")]
    _write_text(output_path, "".join(f"{value}\n" for value in sorted(set(values))))


# Structured-data and subnet helpers.
def json_arrays(
    input_path: str | Path,
    output_path: str | Path,
    keys: Sequence[str],
) -> None:
    data = json.loads(Path(input_path).read_text(encoding="utf-8"))
    values: list[object] = []
    for key in keys:
        value = data[key]
        if not isinstance(value, list):
            raise TypeError(f"JSON field {key!r} must be an array")
        values.extend(value)
    _write_text(output_path, "".join(f"{value}\n" for value in values))


def split_subnets(
    input_path: str | Path,
    ipv4_path: str | Path,
    ipv6_path: str | Path,
) -> None:
    ipv4: list[str] = []
    ipv6: list[str] = []
    for line in Path(input_path).read_text(encoding="utf-8").splitlines():
        value = line.strip()
        if not value:
            continue
        network = ipaddress.ip_network(value, strict=False)
        (ipv4 if network.version == 4 else ipv6).append(line)
    _write_text(ipv4_path, "".join(f"{line}\n" for line in ipv4))
    _write_text(ipv6_path, "".join(f"{line}\n" for line in ipv6))


def cidrs_by_asn(
    asn: str,
    input_path: str | Path,
    output_path: str | Path,
) -> None:
    matches: list[str] = []
    for line in Path(input_path).read_text(encoding="utf-8").splitlines():
        fields = line.split()
        if len(fields) >= 2 and fields[1] == asn:
            matches.append(fields[0])
    _write_text(output_path, "".join(f"{value}\n" for value in matches))


def exclude_lines(
    input_path: str | Path,
    exclusions_path: str | Path,
    output_path: str | Path,
) -> None:
    exclusions = set(Path(exclusions_path).read_text(encoding="utf-8").splitlines())
    lines = Path(input_path).read_text(encoding="utf-8").splitlines()
    _write_text(output_path, "".join(f"{line}\n" for line in lines if line not in exclusions))


def build_parser() -> argparse.ArgumentParser:
    # The CLI remains useful for one-off maintenance, while generators import functions directly.
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)

    command = commands.add_parser("ensure-eof-newline")
    command.add_argument("paths", nargs="+", type=Path)

    for name in ("cleanup", "yaml", "yaml-subdomains", "yaml-payload"):
        command = commands.add_parser(name)
        command.add_argument("input", type=Path)
        command.add_argument("output", type=Path)

    command = commands.add_parser("sort-yaml")
    command.add_argument("input", type=Path)
    command.add_argument("output", type=Path)
    command.add_argument("section", nargs="?", default="payload")

    command = commands.add_parser("json-arrays")
    command.add_argument("input", type=Path)
    command.add_argument("output", type=Path)
    command.add_argument("keys", nargs="+")

    command = commands.add_parser("split-subnets")
    command.add_argument("input", type=Path)
    command.add_argument("ipv4", type=Path)
    command.add_argument("ipv6", type=Path)

    command = commands.add_parser("cidrs-by-asn")
    command.add_argument("asn")
    command.add_argument("input", type=Path)
    command.add_argument("output", type=Path)

    command = commands.add_parser("exclude-lines")
    command.add_argument("input", type=Path)
    command.add_argument("exclusions", type=Path)
    command.add_argument("output", type=Path)
    return parser


def main() -> None:
    args = build_parser().parse_args()
    if args.command == "ensure-eof-newline":
        ensure_eof_newline(args.paths)
    elif args.command == "cleanup":
        clean_lines(args.input, args.output)
    elif args.command == "yaml":
        lines_to_yaml(args.input, args.output)
    elif args.command == "yaml-subdomains":
        lines_to_yaml(args.input, args.output, subdomains=True)
    elif args.command == "sort-yaml":
        sort_yaml_section(args.input, args.output, args.section)
    elif args.command == "yaml-payload":
        yaml_payload(args.input, args.output)
    elif args.command == "json-arrays":
        json_arrays(args.input, args.output, args.keys)
    elif args.command == "split-subnets":
        split_subnets(args.input, args.ipv4, args.ipv6)
    elif args.command == "cidrs-by-asn":
        cidrs_by_asn(args.asn, args.input, args.output)
    elif args.command == "exclude-lines":
        exclude_lines(args.input, args.exclusions, args.output)


if __name__ == "__main__":
    main()
