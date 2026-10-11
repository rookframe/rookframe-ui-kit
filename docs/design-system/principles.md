# Rookframe UI design principles

## 1. The interface MUST feel tactile.

Digital actions should feel like handling believable objects. Controls have
substance: surfaces, edges, depth, and a convincing response to interaction.
Pressing, lifting, placing, and opening should feel distinct.

Tactility comes from appearance and behavior together. Texture alone is
insufficient. Materials enrich the experience while text, states, and actions
remain clear.

**Discarded alternative:** An abstract interface that prioritizes visual economy
and neutrality, treating physical character and material response as optional
decoration.

## 2. The shared tabletop MUST take precedence over information density.

During play, the interface should leave room to inhabit the Scene. We accept an
extra action to inspect equipment, open a character sheet, or reach an occasional
tool when that keeps the tabletop central.

Persistent panels must earn their space. Common actions remain nearby; detailed
information and substantial tasks open deliberately. This prioritizes spatial
presence over simultaneous access to every tool.

**Discarded alternative:** A dashboard that keeps statistics, inventories, logs,
and tools simultaneously visible to minimize navigation, even when they occupy
most of the screen.

## 3. World building, running a game, and playing MUST have distinct interfaces within one design system.

World builders compose and revise. Game masters present situations and coordinate
play. Players understand their situation and act through their characters. Each
activity deserves its own tool arrangements, workflows, and information priorities.

The same person may move between these activities; their current task determines
the interface. Shared materials, controls, states, and interaction conventions
provide continuity without requiring identical workspaces.

**Discarded alternative:** One universal workspace adapted mainly through
permissions and hidden controls, favoring a single arrangement to learn and
maintain over experiences tailored to each activity.

## 4. Interface controls MUST use shared recipes. Themes change appearance while preserving purpose and behavior.

A screen selects a complete usage recipe. Rookframe owns the control's purpose,
composition, behavior, interaction states, focus handling, and responsive layout
contracts.

The design has three layers:

| Layer | Describes | Owner |
| --- | --- | --- |
| **Usage** | Semantic identity: what the element is, including its purpose and emphasis, such as a primary menu button, a selectable row, or a destructive action | Rookframe |
| **State** | Semantic condition: how interaction or its absence affects it, such as enabled, disabled, resting, hovered, pressed, focused, selected, expanded, or pending, as applicable | Rookframe |
| **Material** | Actual design values: surface treatments, typography, colors, textures, dimensions, spacing, borders, depth, shadows, and motion values | Rookframe or a Package |

**Usage and State design tokens are semantic only. Only Material contains actual
design values.** This includes shared defaults: a usage recipe or state token
cannot embed a color, font size, spacing value, duration, or other visual literal.

**The theme maps each element property to a Material token according to its
Usage and State: `Theme(Usage, State, Property) → Material token`.**
The surface, label, icon, border, and other properties can each use different
Material tokens. The theme supplies those references rather than forming a
fourth layer or storing additional design values. Rookframe defines each
element's usage, applicable states, and themeable properties; the theme chooses
their visual expression while preserving their meaning and required distinctions.

State dimensions can coexist. An enabled button may be resting, hovered, or
pressed; focus can accompany each of those states. Selection, expansion, and
pending status apply where the control supports them.

For example, **Worlds**, **Installed Packages**, and **Settings** use
`menu.button.standard`; **Open World** uses `menu.button.primary`. For an enabled,
resting, unfocused primary button, a theme may map the surface to brass, the label
to ivory ink, the icon to a brass highlight, and the shadow to a shallow raised
treatment. Each is a separate property mapping. Its pressed state receives a
depressed treatment; focus adds a visible indicator independently. Another theme
can use blackened steel for the same usage and states.

A theme Package supplies the mappings and any additional Material resources,
and may reuse public Rookframe resources. It declares an ordinary **Godot Theme**
resource with its visual assets. Built-in themes follow exactly the same contract.
Usage and State definitions remain Rookframe-owned.

The World selects the theme for its game interface, Builder tools, and Package
screens. Participant accessibility preferences take precedence, and a built-in
theme provides the fallback. The Manager retains its separate application theme.

Theme selection is a **proposed capability**, requiring a selection contract and
consistent use of shared theme properties.

**Discarded alternative:** Letting each screen or Package invent its own controls
and styling for greater local freedom, with consistency maintained through
guidelines rather than shared recipes. Allowing themes to redefine an element's
usage or state semantics instead of preserving the shared interaction vocabulary.