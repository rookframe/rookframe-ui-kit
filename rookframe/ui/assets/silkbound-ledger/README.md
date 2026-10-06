# Silkbound Ledger assets

The linen is copied byte-for-byte from the approved Rookframe design system at
`rookframe-godot` revision `0f1d5c3edf4ac563a777dd93cc743a4daeaacdd3`.
The ribbon translates the approved CSS gradients and notch into a stock SVG texture.
It is decoration: use TextureRect with mouse_filter Ignore, 28 × 100 desktop,
20 × 68 tablet, and omit on phone. Apply linen once to the owning surface.

`theme/silkbound_theme.tres` supplies native task variations and 44px icon actions
(`SilkIcon`, `SilkPrimaryIcon`). The font resources use the full licensed
EB Garamond faces; they support the Creature sheet's English and Russian.
Regional CJK companions require a locale-selected fallback before those locales
are offered by a migrated surface. Existing surfaces migrate explicitly.
