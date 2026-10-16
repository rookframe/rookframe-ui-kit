# Chronicle surface

`res://rookframe/ui/chronicle/ChronicleSurface.tscn` is a native PanelContainer
for retained narrative: event histories, session recaps, quest journals and
discovered lore. It inherits the consumer Theme without selecting appearance.

Add one ordinary Container child. Use `chronicle_heading`, `chronicle_body` and
`chronicle_meta` on Labels and `chronicle_divider` on an HSeparator. Append
`__compact` to the surface and companion variations for compact density.
Native Theme content margins supply reading padding. Let narrative text wrap.

For a bounded history, place a ScrollContainer inside the surface and the entry
Container inside it. Hosts own storage, timestamps, ordering, filtering, links
and scroll position. Keep actions in a separate toolbar.

This surface does not imply selection, editing, warning severity or unread state.
Use `menu_world_record` for a single World summary and `editor_surface_log` for
a compact latest-activity strip. Use Chronicle when content forms a retained
history or document.
