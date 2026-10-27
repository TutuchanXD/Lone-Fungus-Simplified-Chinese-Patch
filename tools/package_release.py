#!/usr/bin/env python3
"""Repackage the preview.2 installer fix; no game DAT or new patch generation."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import tempfile
import zipfile


BASE_ZIP_SHA256 = "A6B120FA9B9F3F44EFB1FC4EAD7E2C0B60096DACA4D8C08D5645E7ACE8122B46"
VERSION = "0.1.0-preview.2"
PATCH_NAME = "LoneFungus.zh-CN.v0.1.0-preview.1.zstpatch"
PATCH_SHA256 = "FE7E5EAAFE02A64B7F3148CB0C83ECD4462C59CB3503769CDB09E9342761CAFF"
ZSTD_SHA256 = "8076AAE03FEAC7C66B319579E82172EED168DEED2A3F25E5E2D3C60F55E84111"
SOURCE_SHA256 = "3D393F2160A5868B51AB07F5EEE246EBF297151F9C841C3AF3F300B2B0818FDB"
TARGET_SHA256 = "7FB74B7E333B4B274038678D68BA23138A89CB7CC56D5938DAB698470EFB48EA"
SOURCE_FILES = (
    "CHANGELOG.md",
    "LICENSE-SCRIPTS",
    "README.md",
    "THIRD_PARTY_NOTICES.md",
    "docs/TECHNICAL_NOTES.md",
    "docs/RELEASING.md",
    "docs/RELEASE_VALIDATION_v0.1.0-preview.2.md",
    "install.cmd",
    "install.ps1",
    "licenses/Fusion-Pixel-Font-OFL.txt",
    "licenses/Zstandard-LICENSE",
    "manifest.json",
    "uninstall.cmd",
    "uninstall.ps1",
)


def sha256(data):
    return hashlib.sha256(data).hexdigest().upper()


def require(condition, message):
    if not condition:
        raise ValueError(message)


def build(base_zip, output_dir):
    with base_zip.open("rb") as stream:
        require(hashlib.file_digest(stream, "sha256").hexdigest().upper() == BASE_ZIP_SHA256,
                "Base ZIP does not match the published preview.1 SHA-256")

    with zipfile.ZipFile(base_zip) as archive:
        payload = {PATCH_NAME: archive.read(PATCH_NAME), "zstd.exe": archive.read("zstd.exe")}
    require(sha256(payload[PATCH_NAME]) == PATCH_SHA256, "Patch SHA-256 mismatch")
    require(len(payload[PATCH_NAME]) == 98132044, "Patch size mismatch")
    require(sha256(payload["zstd.exe"]) == ZSTD_SHA256, "Zstandard SHA-256 mismatch")

    root = Path(__file__).resolve().parents[1]
    for name in SOURCE_FILES:
        data = (root / name).read_bytes()
        # Respect the repository's .gitattributes on every build host.
        data = data.replace(b"\r\n", b"\n")
        if name.endswith((".ps1", ".cmd")):
            data = data.replace(b"\n", b"\r\n")
        payload[name] = data

    manifest = json.loads(payload["manifest.json"])
    require(manifest["patchVersion"] == VERSION, "Manifest release version mismatch")
    require(manifest["patch"]["file"] == PATCH_NAME, "Manifest patch filename mismatch")
    require(manifest["patch"]["sha256"] == PATCH_SHA256, "Manifest patch SHA-256 mismatch")
    require(manifest["patch"]["size"] == len(payload[PATCH_NAME]), "Manifest patch size mismatch")
    require(manifest["source"]["sha256"] == SOURCE_SHA256, "Source DAT hash changed")
    require(manifest["target"]["sha256"] == TARGET_SHA256, "Target DAT hash changed")

    for name in ("install.ps1", "uninstall.ps1"):
        script = payload[name].decode("utf-8").replace("\r\n", "\n")
        require(not re.search(r"\[string\]\$GameDirectory\s*=", script),
                f"{name}: default-parameter regression")
        require("if ([string]::IsNullOrWhiteSpace($GameDirectory)) {\n"
                "    $GameDirectory = $PSScriptRoot\n}" in script,
                f"{name}: missing PR #2 fix")
        require(f"$SourceHash = '{SOURCE_SHA256}'" in script and
                f"$TargetHash = '{TARGET_SHA256}'" in script,
                f"{name}: unexpected DAT hashes")
    installer = payload["install.ps1"].decode("utf-8")
    require(f"$PatchName = '{PATCH_NAME}'" in installer, "Installer patch name mismatch")
    require(f"$PatchHash = '{PATCH_SHA256}'" in installer, "Installer patch hash mismatch")
    require(f"$ZstdHash = '{ZSTD_SHA256}'" in installer, "Installer tool hash mismatch")

    checksum_lines = [f"{sha256(payload[name])} *{name}\r\n" for name in sorted(payload)]
    payload["CHECKSUMS.sha256"] = "".join(checksum_lines).encode("ascii")
    output_dir.mkdir(parents=True, exist_ok=True)
    zip_name = f"Lone-Fungus-Simplified-Chinese-Patch-v{VERSION}.zip"
    zip_path = output_dir / zip_name
    checksum_path = output_dir / (zip_name + ".sha256")
    require(not zip_path.exists() and not checksum_path.exists(), "Output files already exist")

    with tempfile.TemporaryDirectory(prefix="lf-package-", dir=output_dir) as temporary:
        staged_zip = Path(temporary) / zip_name
        with zipfile.ZipFile(staged_zip, "w", compression=zipfile.ZIP_DEFLATED,
                             compresslevel=9) as archive:
            for name in sorted(payload):
                entry = zipfile.ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
                entry.create_system = 3
                entry.external_attr = 0o100644 << 16
                entry.compress_type = zipfile.ZIP_DEFLATED
                archive.writestr(entry, payload[name], compresslevel=9)
        with zipfile.ZipFile(staged_zip) as archive:
            require(set(archive.namelist()) == set(payload), "Unexpected archive contents")
            for name, expected in payload.items():
                require(archive.read(name) == expected, f"Archive round-trip mismatch: {name}")
        with staged_zip.open("rb") as stream:
            digest = hashlib.file_digest(stream, "sha256").hexdigest().upper()
        staged_zip.replace(zip_path)
    checksum_path.write_bytes(f"{digest} *{zip_name}\r\n".encode("ascii"))
    print(f"ZIP: {zip_path}")
    print(f"SHA-256: {digest}")
    print(f"Files: {len(payload)}; patch and zstd.exe unchanged; no complete game DAT")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-zip", required=True, type=Path,
                        help="Verified preview.1 release ZIP")
    parser.add_argument("--output-dir", type=Path, default=Path("dist"))
    args = parser.parse_args()
    try:
        build(args.base_zip, args.output_dir)
    except (OSError, ValueError, KeyError, zipfile.BadZipFile) as error:
        parser.exit(1, f"ERROR: {error}\n")


if __name__ == "__main__":
    main()
