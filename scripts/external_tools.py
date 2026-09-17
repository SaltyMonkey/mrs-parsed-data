#!/usr/bin/env python3
"""Validated subprocess wrappers for Mihomo and bgpq4."""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import subprocess
import tempfile
from typing import Sequence


DEFAULT_BGPQ4_SOURCES = "RPKI,AFRINIC,APNIC,ARIN,LACNIC,RIPE,RADB"
DEFAULT_MIHOMO = str(Path(__file__).resolve().parent.parent / "mihomo")


def _asn_argument(asn: str) -> str:
    if asn.lower().startswith("as"):
        asn = asn[2:]
    return f"as{asn}"


def run_mihomo(
    rule_type: str,
    input_path: str | Path,
    output_path: str | Path,
    executable: str = DEFAULT_MIHOMO,
) -> None:
    # check=True makes a broken conversion stop the generator instead of publishing stale output.
    subprocess.run(
        [executable, "convert-ruleset", rule_type, "yaml", str(input_path), str(output_path)],
        check=True,
    )


def run_bgpq4(
    family: str,
    output_path: str | Path,
    asns: Sequence[str],
    executable: str = "bgpq4",
    sources: str = DEFAULT_BGPQ4_SOURCES,
) -> None:
    if family not in {"-4", "-6"}:
        raise ValueError("family must be '-4' or '-6'")

    output = Path(output_path)
    output.parent.mkdir(parents=True, exist_ok=True)
    command = [
        executable,
        "-S",
        sources,
        "-A",
        "-F",
        "%n/%l\n",
        family,
        *(_asn_argument(asn) for asn in asns),
    ]
    # Capture only stdout; stderr stays visible in CI where it can actually help.
    result = subprocess.run(command, check=True, stdout=subprocess.PIPE, text=True)

    # Do not truncate a valid previous result until bgpq4 has completed successfully.
    temporary_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="w",
            encoding="utf-8",
            newline="\n",
            dir=output.parent,
            prefix=f".{output.name}.bgpq4.",
            delete=False,
        ) as temporary_file:
            temporary_path = Path(temporary_file.name)
            temporary_file.write(result.stdout)
            if result.stdout and not result.stdout.endswith("\n"):
                temporary_file.write("\n")
        os.replace(temporary_path, output)
    finally:
        if temporary_path is not None:
            temporary_path.unlink(missing_ok=True)


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)

    command = commands.add_parser("mihomo")
    command.add_argument("rule_type", choices=("domain", "ipcidr"))
    command.add_argument("input", type=Path)
    command.add_argument("output", type=Path)
    command.add_argument("--executable", default=DEFAULT_MIHOMO)

    command = commands.add_parser("bgpq4")
    command.add_argument("family", choices=("4", "6"))
    command.add_argument("output", type=Path)
    command.add_argument("asns", nargs="+")
    command.add_argument("--executable", default="bgpq4")
    command.add_argument("--sources", default=DEFAULT_BGPQ4_SOURCES)
    return parser


def main() -> None:
    args = build_parser().parse_args()
    if args.command == "mihomo":
        run_mihomo(args.rule_type, args.input, args.output, args.executable)
    elif args.command == "bgpq4":
        run_bgpq4(
            f"-{args.family}",
            args.output,
            args.asns,
            executable=args.executable,
            sources=args.sources,
        )


if __name__ == "__main__":
    main()
