# Menu choice evidence

Captured from Godot 4.7.2 on 2026-10-11 using `tests/menu_choice.gd`.
The text, hover band, checked item and popup are live native controls.
The Fantasy frame reuses the existing walnut cartouche and brass finial artwork.

| State | Capture |
| --- | --- |
| Fantasy, regular, English selected and Deutsch focused | [Open tray](fantasy-regular-open.png) |
| Fantasy, keyboard focus on the closed field | [Focused field](fantasy-regular-focused.png) |
| Fantasy, compact | [Compact tray](fantasy-compact-open.png) |
| Fantasy, disabled | [Disabled field](fantasy-regular-disabled.png) |
| Cyberpunk, virtual surfaces | [Open tray](cyberpunk-regular-open.png) |
| Fantasy, selected item scrolled into view above a low trigger | [Long list](fantasy-long-list.png) |

Validation:

- `tests/menu_choice_focus.gd`: PASS with a graphical renderer. Pixel comparisons
  catch the reported pale focus bars and require a visible focus response on both
  brass fittings. Covers normal, hover, pressed/open and disabled states at both
  densities and at 1×/1.25× scale. Focus now lights the existing frame texture in
  place, so it follows the pressed offset without drawing flat bars on the wood.
- `tests/menu_choice.gd`: PASS, headless and graphical. Native keyboard and mouse
  selection; repeated reopening; disabled-item skipping; Escape and outside
  dismissal; selection metadata and signal count; long lists; live theme and
  density changes; RTL; fractional scaling.
- `tests/current_design_system.gd`: PASS, including theme/density round trips,
  the existing menu button states, and catalogue layout at 800 and 1440 px.
- Editor import: no script or resource errors. The existing nested consumer
  project is intentionally ignored by the editor.

Reproduce:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/menu_choice.gd
/Applications/Godot.app/Contents/MacOS/Godot --path . --script res://tests/menu_choice.gd -- --capture-dir=/tmp/menu-choice
/Applications/Godot.app/Contents/MacOS/Godot --path . --script res://tests/menu_choice_focus.gd -- --capture-dir=/tmp/menu-choice-focus
```

Run `tests/menu_choice.gd` with `-- --preview` to leave the interactive Fantasy
example open. The capture run ignores real desktop pointer and focus changes
so they cannot interfere with its injected native input events.
