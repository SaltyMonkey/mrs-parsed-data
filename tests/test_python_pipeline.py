from contextlib import ExitStack, redirect_stdout
import io
from pathlib import Path
import subprocess
import tempfile
import unittest
from urllib.error import HTTPError
from unittest.mock import patch

from scripts.collapse_subnets import collapse_file
from scripts.download_file import UnexpectedHTTPStatus, download_file, download_source
from scripts.external_tools import run_bgpq4, run_mihomo
from scripts.file_operations import (
    clean_lines,
    json_arrays,
    lines_to_yaml,
    merge_unique,
    sort_yaml_section,
    yaml_payload,
)
import update_categories_list as categories
import update_services_list as services
from update_justclash_list import readable_name


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

    @patch("scripts.download_file.urlopen")
    def test_http_non_200_keeps_existing_destination(self, urlopen) -> None:
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory) / "rules.txt"
            destination.write_text("old\n", encoding="utf-8")
            response = io.BytesIO(b"new\n")
            response.status = 204
            urlopen.return_value = response

            self.assertFalse(download_source("https://example.invalid/", destination))
            self.assertEqual(destination.read_text(encoding="utf-8"), "old\n")

            urlopen.side_effect = HTTPError("https://example.invalid/", 503, "down", None, None)
            self.assertFalse(download_source("https://example.invalid/", destination))
            self.assertEqual(destination.read_text(encoding="utf-8"), "old\n")

            urlopen.side_effect = None
            response = io.BytesIO(b"new\n")
            response.status = 200
            urlopen.return_value = response
            self.assertTrue(download_source("https://example.invalid/", destination))
            self.assertEqual(destination.read_text(encoding="utf-8"), "new\n")

    @patch("scripts.download_file.urlopen")
    def test_every_http_download_requires_200(self, urlopen) -> None:
        with tempfile.TemporaryDirectory() as directory:
            destination = Path(directory) / "rules.txt"
            destination.write_text("old\n", encoding="utf-8")
            response = io.BytesIO(b"new\n")
            response.status = 204
            urlopen.return_value = response

            with self.assertRaises(UnexpectedHTTPStatus):
                download_file("https://example.invalid/", destination)
            self.assertEqual(destination.read_text(encoding="utf-8"), "old\n")


class FileOperationTests(unittest.TestCase):
    def test_failed_http_sources_keep_outputs_while_successful_sources_update(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory) / "services"
            yaml_folder = folder / "yaml"
            yaml_folder.mkdir(parents=True)
            for stem in ("failed", "updated", "kinozal"):
                (yaml_folder / f"{stem}.yaml").write_text("payload: [old]\n", encoding="utf-8")
                (folder / f"{stem}.mrs").write_bytes(b"old")
            (folder / "failed.txt").write_text("stale\n", encoding="utf-8")

            sources = (
                ("https://example.invalid/failed.yaml", "failed.yaml"),
                ("https://example.invalid/updated.yaml", "updated.yaml"),
            )
            kinozal_sources = (
                ("https://example.invalid/kinozal-one", "kinozal-one.txt"),
                ("https://example.invalid/kinozal-two", "kinozal-two.txt"),
            )

            def fake_download(_url, destination):
                if destination.name == "updated.yaml":
                    destination.write_text("payload: [new]\n", encoding="utf-8")
                    return True
                if destination.name == "kinozal-one.txt":
                    destination.write_text("one\n", encoding="utf-8")
                    return True
                return False

            def fake_mihomo(_rule_type, _source, output):
                Path(output).write_bytes(b"new")

            with ExitStack() as stack:
                for name, value in (
                    ("FOLDER", folder),
                    ("YAML_FOLDER", yaml_folder),
                    ("SOURCES", sources),
                    ("KINOZAL_SOURCES", kinozal_sources),
                    ("MANUAL_FILES", {}),
                    ("download_source", fake_download),
                    ("run_mihomo", fake_mihomo),
                ):
                    stack.enter_context(patch.object(services, name, value))
                with redirect_stdout(io.StringIO()):
                    services.main()

            for stem in ("failed", "kinozal"):
                self.assertEqual((yaml_folder / f"{stem}.yaml").read_text(encoding="utf-8"), "payload: [old]\n")
                self.assertEqual((folder / f"{stem}.mrs").read_bytes(), b"old")
            self.assertIn("new", (yaml_folder / "updated.yaml").read_text(encoding="utf-8"))
            self.assertEqual((folder / "updated.mrs").read_bytes(), b"new")
            self.assertFalse((folder / "failed.txt").exists())
            self.assertFalse((folder / "kinozal.txt").exists())
            self.assertFalse((folder / "kinozal-one.txt").exists())

    def test_incomplete_category_merge_keeps_previous_ruleset(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory) / "block"
            yaml_folder = folder / "yaml"
            yaml_folder.mkdir(parents=True)
            (yaml_folder / "category-ru.yaml").write_text("payload: [old]\n", encoding="utf-8")
            (folder / "category-ru.mrs").write_bytes(b"old")
            sources = (
                ("https://example.invalid/mailru.txt", "mailru.txt"),
                ("https://example.invalid/standalone.yaml", "standalone.yaml"),
            )

            def fake_download(_url, destination):
                if destination.name == "mailru.txt":
                    destination.write_text("one\n", encoding="utf-8")
                else:
                    destination.write_text("payload: [new]\n", encoding="utf-8")
                return True

            def fake_mihomo(_rule_type, _source, output):
                Path(output).write_bytes(b"new")

            with ExitStack() as stack:
                for name, value in (
                    ("FOLDER", folder),
                    ("YAML_FOLDER", yaml_folder),
                    ("SOURCES", sources),
                    ("download_source", fake_download),
                    ("run_mihomo", fake_mihomo),
                ):
                    stack.enter_context(patch.object(categories, name, value))
                with redirect_stdout(io.StringIO()):
                    categories.main()

            self.assertEqual((yaml_folder / "category-ru.yaml").read_text(encoding="utf-8"), "payload: [old]\n")
            self.assertEqual((folder / "category-ru.mrs").read_bytes(), b"old")
            self.assertEqual((folder / "standalone.mrs").read_bytes(), b"new")
            self.assertFalse((folder / "mailru.mrs").exists())

    def test_category_merges_keep_standalone_source(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            folder = Path(directory) / "block"
            yaml_folder = folder / "yaml"
            source_names = (
                "mailru.txt", "kaspersky.txt", "drweb.txt", "categ-ru.txt",
                "yandex.txt", "guberniev-include.txt", "itdog-russia-inside.txt",
            )
            sources = tuple((f"mock:{name}", name) for name in source_names)

            def fake_download(_url, destination):
                destination.write_text("sample\n", encoding="utf-8")
                return True

            def fake_mihomo(_rule_type, _source, output):
                Path(output).write_bytes(b"compiled")

            with ExitStack() as stack:
                for name, value in (
                    ("FOLDER", folder),
                    ("YAML_FOLDER", yaml_folder),
                    ("SOURCES", sources),
                    ("download_source", fake_download),
                    ("run_mihomo", fake_mihomo),
                ):
                    stack.enter_context(patch.object(categories, name, value))
                with redirect_stdout(io.StringIO()):
                    categories.main()

            for stem in ("category-ru", "just-domains", "itdog-russia-inside"):
                self.assertEqual((folder / f"{stem}.mrs").read_bytes(), b"compiled")
            for stem in ("mailru", "guberniev-include"):
                self.assertFalse((folder / f"{stem}.mrs").exists())

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

    def test_domain_formatting_and_cleaning(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            source = root / "source.txt"
            cleaned = root / "cleaned.txt"
            yaml_file = root / "rules.yaml"
            payload = root / "payload.txt"
            source.write_text("wdfiles.com \n.ua\n*.example.com\n+.test.com\n", encoding="utf-8")

            clean_lines(source, cleaned)
            lines_to_yaml(cleaned, yaml_file, subdomains=True)
            yaml_payload(yaml_file, payload)

            self.assertEqual(
                payload.read_text(encoding="utf-8"),
                "+.example.com\n+.test.com\n+.ua\n+.wdfiles.com\n",
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
