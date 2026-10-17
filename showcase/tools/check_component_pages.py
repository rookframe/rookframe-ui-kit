"""Keep native component views complete as the public catalogue grows."""
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[2]
SHOWCASE = ROOT / "showcase"
CATEGORIES = {
    "Actions", "Forms & selection", "Navigation", "Layout", "Surfaces",
    "Data display", "Feedback & overlays",
}


def main():
    catalogue = json.loads((ROOT / "ui-kit/rookframe/ui/catalogue.json").read_text())
    entries = []
    for manifest in sorted((SHOWCASE / "examples/components/manifests").glob("*.json")):
        entries.extend(json.loads(manifest.read_text()))
    ids, scripts, covered = set(), set(), set()
    for entry in entries:
        assert re.fullmatch(r"[a-z][a-z0-9_]*", entry["id"]), entry
        assert entry["id"] not in ids, f"Duplicate route: {entry['id']}"
        ids.add(entry["id"])
        assert entry["category"] in CATEGORIES, entry
        assert entry["title"] and entry["description"], entry
        assert entry["script"] not in scripts, f"Shared page implementation: {entry['script']}"
        scripts.add(entry["script"])
        path = SHOWCASE / entry["script"].removeprefix("res://")
        assert path.is_file(), f"Missing page: {path}"
        assert "static func build(page" in path.read_text(), f"Missing builder: {path}"
        covered.update(entry["covers"])
    expected = {c.get("scene", c.get("script")) for c in catalogue["components"]}
    expected.update(c["script"] for c in catalogue.get("behaviorResources", []))
    expected.update(catalogue["currentDesignSystem"]["components"])
    expected.update(c["name"] for c in catalogue["expansionCapabilities"])
    missing = expected - covered
    assert not missing, "Unrepresented public components/capabilities:\n" + "\n".join(sorted(missing))
    assert {entry["category"] for entry in entries} == CATEGORIES
    print(f"COMPONENT_PAGES: {len(entries)} dedicated views cover {len(expected)} public resources/capabilities")


if __name__ == "__main__":
    main()
