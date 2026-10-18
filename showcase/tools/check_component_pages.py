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
        resources = [p for p in entry["covers"] if p.startswith("res://rookframe/ui/")]
        assert resources, f"No public UI Kit resource for {entry['id']}"
        for resource in resources:
            assert (ROOT / "ui-kit" / resource.removeprefix("res://")).is_file(), f"Non-core component: {resource}"
        covered.update(entry["covers"])
    expected = {c.get("scene", c.get("script", c.get("resource"))) for c in catalogue["components"]}
    expected.update(c["script"] for c in catalogue.get("behaviorResources", []))
    expected.update(catalogue["currentDesignSystem"]["components"])
    expected.update(c["name"] for c in catalogue["expansionCapabilities"])
    missing = expected - covered
    assert not missing, "Unrepresented public components/capabilities:\n" + "\n".join(sorted(missing))
    assert {entry["category"] for entry in entries} == CATEGORIES
    # Pages use core resources; only the catalogue host imports preview Themes.
    catalogue_host = SHOWCASE / "examples/components/catalogue.gd"
    preview_themes = {
        f"res://rookframe/ui/themes/{name}/theme.tres":
            ROOT / "themes" / name / "rookframe/ui/themes" / name / "theme.tres"
        for name in ("silkbound-ledger", "fantasy", "cyberpunk")
    }
    for source in (SHOWCASE / "examples/components").rglob("*"):
        if source.suffix not in {".gd", ".tscn", ".json"}:
            continue
        text = source.read_text()
        if source != catalogue_host:
            assert not re.search(r"fantasy|cyberpunk|silkbound", text, re.IGNORECASE), source
        for ref in re.findall(r'"(res://[^"\n]+)"', text):
            relative = ref.removeprefix("res://")
            if source == catalogue_host and ref in preview_themes:
                assert preview_themes[ref].is_file(), f"Missing preview Theme: {source} -> {ref}"
            elif ref.startswith("res://rookframe/"):
                assert (ROOT / "ui-kit" / relative).exists(), f"Non-core dependency: {source} -> {ref}"
            else:
                assert ref.startswith("res://examples/components/"), f"External specimen dependency: {source} -> {ref}"
    print(f"COMPONENT_PAGES: {len(entries)} dedicated views cover {len(expected)} public resources/capabilities")


if __name__ == "__main__":
    main()
