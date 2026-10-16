#!/usr/bin/env python3
"""Materialize local Godot packages without changing their res:// paths."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil

ROOT = Path(__file__).resolve().parents[1]
CONFIG = json.loads((ROOT / "workspace.json").read_text())
STAMP = ".workspace-install.json"


def sources(packages):
    files, visited = {}, set()

    def collect(name):
        if name in visited:
            return
        visited.add(name)
        package = CONFIG["packages"][name]
        for dependency in package["dependencies"]:
            collect(dependency)
        base = ROOT / package["path"]
        for source in sorted((base / "rookframe/ui").rglob("*")):
            if not source.is_file():
                continue
            relative = source.relative_to(base).as_posix()
            if relative in files:
                raise ValueError(f"Package collision: {relative}")
            files[relative] = source
        # Legal notices travel with every installed package.
        for name in ("LICENSE", "THIRD_PARTY_NOTICES.md"):
            if (base / name).is_file():
                files[f"rookframe/licenses/{base.name}/{name}"] = base / name

    for package in packages:
        collect(package)
    return files


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def install(destination, packages):
    destination = destination.resolve()
    for package in CONFIG["packages"].values():
        source = (ROOT / package["path"]).resolve()
        if destination == source or source in destination.parents or destination in source.parents:
            raise ValueError("Install into a consumer project, outside package sources")
    files = sources(packages)
    stamp = destination / STAMP
    previous = json.loads(stamp.read_text())["files"] if stamp.exists() else {}
    # Refuse to silently overwrite hand-authored consumer resources.
    for relative in set(previous) | set(files):
        target = destination / relative
        if not target.resolve().is_relative_to(destination):
            raise ValueError(f"Install path escapes consumer: {relative}")
        if target.exists() and relative not in previous:
            if relative not in files or target.read_bytes() != files[relative].read_bytes():
                raise ValueError(f"Unmanaged resource: {target}")
    for relative in previous.keys() - files.keys():
        (destination / relative).unlink(missing_ok=True)
    for relative, source in files.items():
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        if not target.exists() or target.read_bytes() != source.read_bytes():
            shutil.copy2(source, target)
    stamp.write_text(json.dumps({"packages": packages, "files": {name: digest(path) for name, path in files.items()}}, indent=2) + "\n")
    print(f"Installed {len(files)} files into {destination}")


def verify(destination, packages):
    files = sources(packages)
    recorded = json.loads((destination / STAMP).read_text())
    expected = {name: digest(source) for name, source in files.items()}
    if recorded != {"packages": packages, "files": expected}:
        raise ValueError("Local packages changed; prepare the consumer again")
    for relative, checksum in expected.items():
        if digest(destination / relative) != checksum:
            raise ValueError(f"Stale installed resource: {relative}")
    for manifest in destination.glob("rookframe/ui/assets/*generated-assets.json"):
        for asset in json.loads(manifest.read_text())["assets"]:
            if digest(destination / "rookframe/ui" / asset["path"]) != asset["sha256"]:
                raise ValueError(f"Asset checksum mismatch: {asset['path']}")
    print(f"Verified {len(files)} local package files and asset provenance")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("command", choices=["prepare", "verify", "install"])
    parser.add_argument("--destination", type=Path)
    parser.add_argument("--theme", action="append", choices=["silkbound-ledger", "fantasy", "cyberpunk"], default=[])
    args = parser.parse_args()
    if args.command == "install":
        if args.destination is None:
            parser.error("install requires --destination")
        install(args.destination, ["ui-kit"] + args.theme)
    else:
        destination = ROOT / CONFIG["showcase"]["path"]
        packages = CONFIG["showcase"]["dependencies"]
        (install if args.command == "prepare" else verify)(destination, packages)


if __name__ == "__main__":
    main()
