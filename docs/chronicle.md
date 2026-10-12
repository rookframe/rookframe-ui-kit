# Auxiliary Chronicle surface: retained narrative

Instance `res://rookframe/ui/chronicle/ChronicleSurface.tscn` with either auxiliary
Fantasy/Cyberpunk Theme. Silkbound Ledger remains canonical; this recipe does
not change the Main Menu or implement System Extension theme selection. **Chronicle means information the player can read now and return to
later.** Fantasy renders it as a real paper scroll with naturally rolled ends,
light edge wear, a quiet reading field and dark ink. Cyberpunk
renders the same role as a dark archive panel with an amber binding stripe,
short top tab and small index marks. The amber treatment identifies retained
records and is always present, independent of warning severity or unread state.
The separate [design specimen](https://github.com/rookframe/rookframe-design-specimen)
shows the same event history in both materials under Shell experiments →
Menu → Surfaces, alongside Structure, Action group and Recent World.

Use this surface for:

- **Event histories:** completed rolls and outcomes, discoveries, world events,
  and player actions worth retaining. Each entry identifies when it happened,
  who or what caused it, and the result. Append entries in chronological order.
- **Session recaps:** a readable account of what happened, with a session name
  or date and short paragraphs.
- **Quest journals:** recorded objectives, clues and progress updates. Put
  accept, track, complete or abandon controls in an adjacent action area.
- **Discovered lore and correspondence:** text the player has acquired and can
  revisit, such as a letter, an inscription or a codex entry.

The scroll does **not** signal a button, editable field, selectable card, live
status, warning severity or an unread state. Use existing stone panels for
structural UI, walnut insets for controls, and action buttons for commands.
The existing `menu_world_record` remains the summary of a single World;
`editor_surface_log` remains a compact latest-activity strip. Use Chronicle
when the content becomes a retained history or document. It is not a skin for
settings, inventory grids, transient toasts, debugging output or urgent alerts.

Compose it as a native `PanelContainer` with one ordinary Container child.
Use the companion Label variations `chronicle_heading`, `chronicle_body` and
`chronicle_meta`, plus `chronicle_divider` for an `HSeparator`. These styles
switch between dark ink on paper and light text on the archive panel; ordinary
menu/editor labels are not suitable on the paper. Append `__compact` to the
surface **and** its text/divider variations for compact density. Content
margins reserve the paper rolls and edges; do not position text or controls over them.
Fantasy reserves 48 px at the sides and 96 px for the top/bottom rolls, plus a
reading gutter of 24 px regular / 16 px compact. This gives **72 / 64 px horizontal
padding** and **120 / 112 px vertical padding** (regular / compact). Cyberpunk's
clean frame uses **30 / 22 px**. These are native Theme content margins, so
ordinary Container children receive the correct padding automatically. Do not
add a second MarginContainer just to recreate this spacing.
Labels should wrap rather than truncate narrative text. The surface sizes to
its content and inherits live Theme changes without a script.

Fantasy keeps both 96 px rolls fixed when the surface grows vertically. The
paper grain and side wear repeat at their original vertical scale instead of
stretching. Mirrored repeats meet without a cut; a soft transition attaches the
last repeat to the bottom roll. Shading beside the rolls stays at the ends, out
of the repeated reading field. Horizontal resizing preserves the 48 px side
edges and stretches the center. Verify the rendering at minimum and extended
heights with `godot --path . --script tests/chronicle_resize.gd` (requires a
graphical renderer).

For a bounded history, place a `ScrollContainer` inside the surface and the
entry Container inside it. The paper and its rolled ends stay fixed while entries
scroll. Hosts own storage, timestamps, ordering, filtering, links and scroll
position; the recipe supplies only presentation. Keep existing entries visible
while a reader browses older events, and offer an explicit jump to the newest
entry when appropriate. Search, filters and other actions belong in a separate
toolbar. The paper is decorative; all meaningful content remains native text.
