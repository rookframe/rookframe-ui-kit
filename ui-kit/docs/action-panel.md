# Action Panel

`res://rookframe/ui/components/surfaces/action_panel/action_panel.tscn` composes
four regions with ordinary Godot Controls. The caller owns content, signals and
system rules. The core owns layout, child identity and presentation sequencing.
The consumer supplies materials, decoration and optional shaders.

Instance the scene with Editable Children or use the public getters:

| Slot | Editor path | Getter |
| --- | --- | --- |
| Header | `Header/Leaf/HeaderSlot` | `get_header_slot()` |
| Emblem | `Header/Emblem/Leaf/EmblemSlot` | `get_emblem_slot()` |
| Sections | `Sections/SectionsSlot` | `get_sections_slot()` |
| Footer | `Footer/Leaf/FooterSlot` | `get_footer_slot()` |

Add `action_section.tscn` instances to the sections slot. Each section accepts
ordinary Container content. `compact` reduces offsets without rebuilding children.
`show_emblem` and `show_footer` control the optional regions.

`animate_open` enables ordered presentation. `reduced_motion` settles immediately.
Hiding or removing a section during an entrance restores native presentation and
input. Content keeps its identity, focus and native signal connections.
`visual_scene` and `ink_shader` are optional presentation inputs; without them,
the component does not supply a surface material or ink effect.

```gdscript
var panel = preload("res://rookframe/ui/components/surfaces/action_panel/action_panel.tscn").instantiate()
add_child(panel)
var section = preload("res://rookframe/ui/components/surfaces/action_panel/action_section.tscn").instantiate()
section.add_child(VBoxContainer.new())
panel.get_sections_slot().add_child(section)
panel.show_footer = false
```

## Hinged leaf

`components/surfaces/hinged_leaf/hinged_leaf.tscn` contains folding content.
Author Controls in `Surface/Viewport/Root/Ink/Content` or use `get_content()`.
Its SubViewport is a separate Theme inheritance boundary; assign the consumer
Theme to the content when needed.

`set_open(open, animate = true)` changes the open state. Read `is_open` and
`animating`, and connect `settled(open)` or `reaction_changed(offset)`.
`reduced_motion` settles immediately. Hiding cancels motion and folds the leaf;
repeated calls replace the active transition. `hinge_gap` and `hinge_inset`
position bindings supplied by the presentation.

Native input and focus remain on source Controls. Temporary 3D presentation
uses stock SubViewports, Camera3D, MeshInstance3D and Tween. The component owns
no category semantics, selection, persistence or host operations.
