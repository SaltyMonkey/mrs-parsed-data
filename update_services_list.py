#!/usr/bin/env python3
"""Generate service domain rulesets without the legacy shell orchestrator."""

from __future__ import annotations

from pathlib import Path

from scripts.download_file import download_file
from scripts.external_tools import run_mihomo
from scripts.file_operations import append_file, lines_to_yaml, remove_files, sort_yaml_section


ROOT = Path(__file__).resolve().parent
FOLDER = ROOT / "services"
YAML_FOLDER = FOLDER / "yaml"
MANUAL_FOLDER = ROOT / "manual/services"

SOURCES = (
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/openstreetmap.yaml", "openstreetmap.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/f-droid.yaml", "f-droid.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/tiktok.yaml", "tiktok.yaml"),
    ("https://beta.iplist.opencck.org/?format=text&data=domains&wildcard=1&site=anydesk.com", "anydesk.txt"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/kinopub.yaml", "kinopub.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/microsoft.yaml", "microsoft.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/hdrezka.yaml", "hdrezka.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/anthropic.yaml", "anthropic.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/openai.yaml", "openai.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/instagram.yaml", "instagram.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/spotify.yaml", "spotify.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/linkedin.yaml", "linkedin.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/x.yaml", "x.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/discord.yaml", "discord.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/netflix.yaml", "netflix.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/telegram.yaml", "telegram.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/github.yaml", "github.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/github-copilot.yaml", "copilot.yaml"),
    ("https://raw.githubusercontent.com/itdoginfo/allow-domains/refs/heads/main/Services/google_play.lst", "google-play.txt"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/google-gemini.yaml", "gemini.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/xbox.yaml", "xbox.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/archive.yaml", "archive.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/alibaba.yaml", "alibaba.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/perplexity.yaml", "perplexity.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/youtube.yaml", "youtube.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/amazon.yaml", "amazon.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/apple.yaml", "apple.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/mongodb.yaml", "mongodb.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/azure.yaml", "azure.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/bilibili.yaml", "bilibili.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/whatsapp.yaml", "whatsapp.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/google-play.yaml", "google-play.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo-lite/geosite/google.yaml", "google.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/akamai.yaml", "akamai.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/netlify.yaml", "netlify.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/twitch.yaml", "twitch.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/amd.yaml", "amd.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/tailscale.yaml", "tailscale.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/ibm.yaml", "ibm.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/oracle.yaml", "oracle.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/redhat.yaml", "redhat.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/intel.yaml", "intel.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/jsdelivr.yaml", "jsdelivr.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/broadcom.yaml", "broadcom.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/qualcomm.yaml", "qualcomm.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/kubernetes.yaml", "kubernetes.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/cisco.yaml", "cisco.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/qt.yaml", "qt.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/canon.yaml", "canon.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/corel.yaml", "corel.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/hp.yaml", "hewlett-packard.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/lenovo.yaml", "lenovo.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/connectivity-check.yaml", "connectivity-check.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/digitalocean.yaml", "digitalocean.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/fastly.yaml", "fastly.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/openwrt.yaml", "openwrt.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/tencent.yaml", "tencent.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/vercel.yaml", "vercel.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/cloudflare.yaml", "cloudflare.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/meta.yaml", "meta.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/artstation.yaml", "artstation.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/npmjs.yaml", "npmjs.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/paypal.yaml", "paypal.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/pixiv.yaml", "pixiv.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/rutracker.yaml", "rutracker.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/hetzner.yaml", "hetzner.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/panasonic.yaml", "panasonic.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/flibusta.yaml", "flibusta.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/nvidia.yaml", "nvidia.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/cdn77.yaml", "cdn77.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/steam.yaml", "steam.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/ea.yaml", "ea.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/mega.yaml", "mega.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/docker.yaml", "docker.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/nintendo.yaml", "nintendo.yaml"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/mailru-group.list", "mailru.txt"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/kaspersky.list", "kaspersky.txt"),
    ("https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/refs/heads/meta/geo/geosite/drweb.list", "drweb.txt"),
)

MANUAL_FILES = {
    "manual-service-ovh": "ovh.txt",
    "manual-service-nix-distros": "nix.txt",
    "manual-service-atlassian": "atlassian.txt",
    "manual-service-twitch-fix": "twitch-fix.txt",
    "manual-service-bunny": "bunny.txt",
    "manual-service-gcore": "gcore.txt",
    "manual-service-dns-test": "dns-test.txt",
}


def main() -> None:
    FOLDER.mkdir(parents=True, exist_ok=True)
    YAML_FOLDER.mkdir(parents=True, exist_ok=True)
    remove_files(FOLDER, ("*.txt", "*.yaml"), recursive=True)

    for url, filename in SOURCES:
        download_file(url, FOLDER / filename)

    for manual_name, output_name in MANUAL_FILES.items():
        append_file(MANUAL_FOLDER / manual_name, FOLDER / output_name)

    for yaml_file in sorted(FOLDER.glob("*.yaml")):
        print(f"Processing YAML: {yaml_file}")
        sort_yaml_section(yaml_file, yaml_file)
        run_mihomo("domain", yaml_file, yaml_file.with_suffix(".mrs"))

    for text_file in sorted(FOLDER.glob("*.txt")):
        print(f"Processing: {text_file}")
        yaml_file = text_file.with_suffix(".yaml")
        lines_to_yaml(text_file, yaml_file, subdomains=True)
        run_mihomo("domain", yaml_file, text_file.with_suffix(".mrs"))

    for yaml_file in FOLDER.glob("*.yaml"):
        yaml_file.replace(YAML_FOLDER / yaml_file.name)
    remove_files(FOLDER, ("*.txt",))


if __name__ == "__main__":
    main()
