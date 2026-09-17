from contextlib import redirect_stdout
import io
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch

from scripts.collapse_subnets import collapse_file
from scripts.download_file import download_file
from scripts.external_tools import run_bgpq4, run_mihomo
from scripts.file_operations import (
    clean_lines,
    json_arrays,
    lines_to_yaml,
    merge_unique,
    sort_yaml_section,
    yaml_payload,
)
from update_justclash_lists import readable_name


class DownloadTests(unittest.TestCase):
    def test_download_replaces_destination_after_success(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source.txt"
            destination = root / "destination.txt"
            source.write_text("new\n", encoding="utf-8")
            destination.write_text("old\n", encoding="utf-8")

            download_file(source.as_uri(), destination)

            self.assertEqual(destination.read_text(encoding="utf-8"), "new\n")

    def test_failed_download_keeps_existing_destination(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            destination = root / "destination.txt"
            destination.write_text("old\n", encoding="utf-8")

            with self.assertRaises(Exception):
                download_file((root / "missing.txt").as_uri(), destination)

            self.assertEqual(destination.read_text(encoding="utf-8"), "old\n")


class FileOperationTests(unittest.TestCase):
    def test_collapse_subnets(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            source = Path(directory) / "subnets.txt"
            source.write_text("192.0.2.0/25\n192.0.2.128/25\n", encoding="utf-8")

            with redirect_stdout(io.StringIO()):
                collapse_file(source)

            self.assertEqual(source.read_text(encoding="utf-8"), "192.0.2.0/24\n")

    def test_domain_pipeline(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source.txt"
            cleaned = root / "cleaned.txt"
            yaml_file = root / "rules.yaml"
            payload = root / "payload.txt"
            source.write_text("# comment\n*.z.example\n\n+.a.example\n", encoding="utf-8")

            clean_lines(source, cleaned)
            lines_to_yaml(cleaned, yaml_file, subdomains=True)
            sort_yaml_section(yaml_file, yaml_file)
            yaml_payload(yaml_file, payload)

            self.assertEqual(
                payload.read_text(encoding="utf-8"),
                "+.a.example\n+.z.example\n",
            )

    def test_json_arrays_and_merge(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            data = root / "data.json"
            first = root / "first.txt"
            second = root / "second.txt"
            merged = root / "merged.txt"
            data.write_text('{"first": ["b", "a"], "second": ["c"]}', encoding="utf-8")

            json_arrays(data, first, ("first", "second"))
            second.write_text("a\nd\n", encoding="utf-8")
            merge_unique((first, second), merged)

            self.assertEqual(merged.read_text(encoding="utf-8"), "a\nb\nc\nd\n")

    def test_justclash_readable_name_keeps_legacy_acronyms(self) -> None:
        self.assertEqual(readable_name("category-ru-ads"), "Category RU ADS")
        self.assertEqual(readable_name("category-ai-cdn"), "Category AI CDN")
        self.assertEqual(readable_name("hagezi-dyndns"), "Hagezi DynDNS")
        self.assertEqual(readable_name("github-copilot"), "GitHub Copilot")
        self.assertEqual(readable_name("f-droid"), "F-Droid")
        self.assertEqual(readable_name("youtube"), "YouTube")
        self.assertEqual(readable_name("category-ecommerce-ru"), "Category eCommerce RU")
        self.assertEqual(readable_name("hagezi-spy-samsung"), "Hagezi spy Samsung")
        self.assertEqual(readable_name("hagezi-spy-xiaomi"), "Hagezi spy Xiaomi")
        self.assertEqual(readable_name("hagezi-spy-vivo"), "Hagezi spy Vivo")


class ExternalToolTests(unittest.TestCase):
    @patch("scripts.external_tools.subprocess.run")
    def test_mihomo_arguments(self, run) -> None:
        run_mihomo("domain", "input.yaml", "output.mrs", executable="mihomo-test")
        run.assert_called_once_with(
            ["mihomo-test", "convert-ruleset", "domain", "yaml", "input.yaml", "output.mrs"],
            check=True,
        )

    @patch("scripts.external_tools.subprocess.run")
    def test_bgpq4_output(self, run) -> None:
        run.return_value = subprocess.CompletedProcess([], 0, stdout="example-prefix")
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "prefixes.txt"

            run_bgpq4("-4", output, ("64500",), executable="bgpq4-test", sources="TEST")

            self.assertEqual(output.read_text(encoding="utf-8"), "example-prefix\n")
            run.assert_called_once_with(
                ["bgpq4-test", "-S", "TEST", "-A", "-F", "%n/%l\n", "-4", "as64500"],
                check=True,
                stdout=subprocess.PIPE,
                text=True,
            )


if __name__ == "__main__":
    unittest.main()
