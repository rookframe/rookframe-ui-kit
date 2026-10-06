# Silkbound Ledger assets

The linen SVG is copied byte-for-byte from the approved Rookframe design system at
`rookframe-godot` revision `0f1d5c3edf4ac563a777dd93cc743a4daeaacdd3`.
The ribbon translates the approved CSS gradients and notch into a stock SVG texture.
It is decoration: use TextureRect with mouse_filter Ignore, 28 × 100 desktop,
20 × 68 tablet, and omit on phone. Apply linen once to the owning surface.

`theme/silkbound_theme.tres` supplies native task variations and 44px icon actions
(`SilkIcon`, `SilkPrimaryIcon`). The font resources use the full licensed
EB Garamond faces; they support the Creature sheet's English and Russian.
Regional CJK companions require a locale-selected fallback before those locales
are offered by a migrated surface. Existing surfaces migrate explicitly.

`linen.png` is the lossless 96 × 96 RGBA runtime tile exported from that SVG
as a repeating CSS background, matching the approved reference at its canonical
1× canvas. Godot's SVG rasterizer produces different coverage for its subpixel
strands; the PNG preserves the approved weave in a stock tiled TextureRect.
Keep the source SVG unchanged. Use the PNG once above the 94% ink surface, with
no extra tint or opacity. Do not stretch the tile.

To regenerate, provide Playwright on `NODE_PATH` and run
`node tools/export-silkbound-linen.cjs /path/to/chromium`. The checked-in export
uses Chromium 149.0.7827.55 on macOS. The script captures an interior repeated
tile; exporting an isolated SVG image does not preserve the reference's edge
coverage. No browser is required at runtime.
