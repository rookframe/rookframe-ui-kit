"""Prepare build-only glyph-addressable copies of the approved fonts.

The shipped FontFiles retain the original TTF bytes, including shaping tables.
These temporary copies let the reference renderer paint the exact glyph IDs
selected by native shaping, including ligatures and tabular figures.
"""
import json
import sys
from pathlib import Path

from fontTools.subset import Options, Subsetter
from fontTools.ttLib import TTFont
from fontTools.ttLib.tables._c_m_a_p import CmapSubtable

TOOLS = Path(__file__).resolve().parent
SOURCE = TOOLS.parents[1] / "rookframe/ui/assets/fonts/eb-garamond"
# The migrated English/Russian UI plus accented names and common symbols.
# Other characters and sizes continue through the original dynamic font.
CHARACTERS = (
    list(range(32, 0x250))
    + list(range(0x300, 0x370))
    + list(range(0x400, 0x530))
    + list(range(0x2000, 0x2070))
    + list(range(0x20A0, 0x20D0))
    + list(range(0x2190, 0x2300))
)


def prepare(destination: Path) -> None:
    destination.mkdir(parents=True, exist_ok=True)
    profiles = json.loads((TOOLS / "profiles.json").read_text())
    for profile in profiles:
        font = TTFont(SOURCE / profile["source"])
        order = font.getGlyphOrder()
        subset = TTFont(SOURCE / profile["source"])
        options = Options()
        options.layout_features = ["ccmp", "locl", "rlig", "liga", "clig", "calt", "tnum"]
        options.glyph_names = True
        selection = Subsetter(options=options)
        selection.populate(unicodes=CHARACTERS)
        selection.subset(subset)
        names = set(subset.getGlyphOrder())
        glyphs = [
            {"glyph": index, "codepoint": 0xF0000 + index}
            for index, name in enumerate(order)
            if index > 0 and name in names
        ]
        table = CmapSubtable.newSubtable(12)
        table.platformID, table.platEncID, table.language = 3, 10, 0
        table.cmap = {item["codepoint"]: order[item["glyph"]] for item in glyphs}
        font["cmap"].tables = [table]
        # Each temporary PUA code point must draw one requested glyph, without
        # applying shaping a second time. The shipped original keeps all tables.
        for tag in ["GSUB", "GPOS", "kern"]:
            if tag in font:
                del font[tag]
        name = profile["name"]
        font.save(destination / f"{name}.ttf")
        (destination / f"{name}.json").write_text(json.dumps(glyphs))
        print(f"{name}: {len(glyphs)} glyphs")
    (destination / "profiles.json").write_text(json.dumps(profiles))


if __name__ == "__main__":
    prepare(Path(sys.argv[1]).resolve())
