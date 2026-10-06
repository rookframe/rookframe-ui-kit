# Silkbound font asset export

The approved HTML reference rasterizes EB Garamond differently from Godot's
unmodified dynamic-font renderer. These build tools record that glyph coverage
in ordinary Godot `FontFile` resources. Runtime Labels, Buttons, LineEdits and
TextEdits remain native. There is no runtime browser, font renderer or shader.

The resources retain the original licensed TTF bytes, shaping tables and full
character coverage. Cached sizes cover the migrated Creature surface; other
characters and sizes use Godot's dynamic font and normal fallback. Latin,
Cyrillic, accents, punctuation, common symbols, ligatures and tabular figures are
prerendered. Font size, OpenType weight and the source font's metrics remain
unchanged. A separate small ink cache preserves coverage for the selected
chapter's dark lettering. The other cache uses the primary text token.

Godot's documented FontFile cache setters and compressed ResourceSaver produce
the runtime `.res` files. An occupied atlas shelf prevents a subsequently
rasterized character from overwriting cached glyphs. These are generated font
assets bound to the pinned Godot toolchain; regenerate when upgrading that
serialization/rendering toolchain.

## Regenerate

Use macOS, FontTools **4.66.1**, Playwright with Chromium **149.0.7827.55**, and
Godot **4.7.2**. The renderer/platform matters because the source authority was
reviewed there. Provide Playwright on `NODE_PATH`. From this repository:

```sh
python3 tools/silkbound-fonts/prepare.py /tmp/silkbound-fonts
node tools/silkbound-fonts/export.cjs /tmp/silkbound-fonts /path/to/chromium
/path/to/Godot --headless --path . --script tools/silkbound-fonts/assemble.gd -- /tmp/silkbound-fonts "$PWD/rookframe/ui/assets/fonts/eb-garamond/prerendered"
```

Use a fresh temporary directory. The temporary fonts address individual glyphs
through private-use code points and omit shaping only for atlas export. They
are **not** distributed. The shipped resources embed the original TTF bytes;
the OFL license and source provenance beside those originals apply.

After generation, run `Godot --headless --path . --script tools/silkbound-fonts/verify.gd`
to reload the saved resources in a fresh Godot process. Verify
the original font bytes, unchanged text measurements, accented Latin/Russian,
ligatures, a character and size outside the cache, and unchanged existing atlas
pixels after fallback. Review the three canonical canvases and native input.

References: [FontFile](https://docs.godotengine.org/en/stable/classes/class_fontfile.html),
[FontVariation](https://docs.godotengine.org/en/stable/classes/class_fontvariation.html).
