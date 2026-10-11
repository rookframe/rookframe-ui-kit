# Switch material and interaction evidence

The two regular-density captures come from `tests/switch.gd` under Godot
4.7.2, scrolled to the Switch section after Buttons in the Menu showcase,
using the shared Structure frame and current Fantasy and Cyberpunk Themes. Fantasy shares the new
buttons' walnut grain, beveled brass casing and inset lettering. Cyberpunk
shares the alloy button faces, cut corners, shadow depth and cyan edge signals.
Related cards sit together in the existing `menu_group` surface: a textured stone
tray in Fantasy and a chassis tray in Cyberpunk, with density-aware inner padding. Selected cards reuse the dropdown checkmark.
The SwitchGroup recipe keeps two, three or more options in a row when they fit,
and stacks the complete group when space is tight.

The standalone suite passes both headless and with the graphical renderer.
It exercises pointer and keyboard selection, exclusive ButtonGroup behaviour,
independent toggles, disabled selection, silent native state updates, theme and
density round-trips, and long copy in narrow and RTL layouts. It also verifies three-way selection, independent groups, five-option reflow,
dynamic additions/removals, the shared dropdown checkmark, and Fantasy’s actual
new button texture and material frame.

Regenerate all states and layouts with:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . --script res://tests/switch.gd -- --capture-dir=/tmp/switch
```

The current design system, MenuChoice, and editor component regression suites
also pass. No legacy component or theme is used by Switch.
