#!/usr/bin/env python3
"""Download one file and replace the destination only after a successful transfer."""

from __future__ import annotations

import argparse
import os
from pathlib import Path
import shutil
import tempfile
from urllib.request import Request, urlopen


def download_file(
    url: str,
    destination: str | Path,
    user_agent: str | None = None,
    timeout: int = 120,
) -> None:
    output_path = Path(destination)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    request = Request(url, headers={"User-Agent": user_agent} if user_agent else {})

    # Keep the temporary file beside the destination: os.replace then stays atomic.
    temporary_path: Path | None = None
    try:
        with tempfile.NamedTemporaryFile(
            mode="wb",
            dir=output_path.parent,
            prefix=f".{output_path.name}.download.",
            delete=False,
        ) as temporary_file:
            temporary_path = Path(temporary_file.name)
            with urlopen(request, timeout=timeout) as response:
                shutil.copyfileobj(response, temporary_file)

        # A failed transfer never replaces the last known-good file.
        os.replace(temporary_path, output_path)
    finally:
        # On success the path is already moved; on failure this removes the debris.
        if temporary_path is not None:
            temporary_path.unlink(missing_ok=True)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("url")
    parser.add_argument("destination", type=Path)
    parser.add_argument("user_agent", nargs="?")
    parser.add_argument("--timeout", type=int, default=120)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    download_file(args.url, args.destination, args.user_agent, args.timeout)


if __name__ == "__main__":
    main()
