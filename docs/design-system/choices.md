# Draft Rookframe UI design choices

Each choice follows the [design principles](principles.md).
Theme Package selection is a proposed feature. Recipe names below are examples.

## 1. Create a base theme

**Principles:** [Principle 1: Tactile interface](principles.md#1-the-interface-must-feel-tactile),
[Principle 2: Tabletop before information density](principles.md#2-the-shared-tabletop-must-take-precedence-over-information-density),
[Principle 4: Shared recipes and theme rules](principles.md#4-interface-controls-must-use-shared-recipes-themes-change-appearance-while-preserving-purpose-and-behavior).

Create one base theme for **Dungeons & Dragons** and **Call of Cthulhu**.
Make controls feel like physical objects. Keep the shared tabletop visible during
play. Use the same theme rules as custom themes.

## 2. Use three layers with theme mappings

**Principle:** [Principle 4: Shared recipes and theme rules](principles.md#4-interface-controls-must-use-shared-recipes-themes-change-appearance-while-preserving-purpose-and-behavior).

Use **Usage**, **State**, and **Material**. The theme maps each element property
to a Material token according to its usage and state:
**`Theme(Usage, State, Property) → Material token`**.

| Layer | Purpose | Owner |
| --- | --- | --- |
| Usage | Semantic identity: what the element is, including its purpose and emphasis | Rookframe |
| State | Semantic condition: how interaction, availability, focus, and other applicable conditions affect it | Rookframe |
| Material | Actual design values, including surfaces, typography, colors, dimensions, spacing, depth, and motion values | Rookframe or a Package |

Usage and State design tokens are **semantic only**. **Only Material contains
actual design values**, including shared defaults. Theme mappings contain
references to Material tokens. Keep all literal colors, dimensions, font choices,
durations, and other visual values in Material.

Map properties independently: one button can use brass for its surface, ivory
ink for its label, and a dark raised shadow. The usage recipe defines the
themeable properties; the theme assigns their Material references for each
applicable state combination.

Theme Packages supply mappings and any additional Material resources; they may
reuse public Rookframe resources. The theme is the mapping, not a fourth layer.
It can change brass to blackened steel while preserving each control's Usage
and State definitions and their required visual distinctions.

## 3. Use complete control recipes

**Principles:** [Principle 1: Tactile interface](principles.md#1-the-interface-must-feel-tactile),
[Principle 4: Shared recipes and theme rules](principles.md#4-interface-controls-must-use-shared-recipes-themes-change-appearance-while-preserving-purpose-and-behavior).

Each usage recipe defines the control's composition, applicable states, and
semantic references for its surface, text, icons, borders, and depth.
Rookframe controls press behavior, focus, and layout changes for different screen
sizes. Themes map each property, given its usage and states, to a Material token
where its concrete visual value is defined.

Enabled buttons have rest, hover, and pressed states. Focus can occur with each
state. Add selection, expansion, and pending states where necessary.

Use `menu.button.standard` for Worlds, Installed Packages, and Settings.
Use `menu.button.primary` for Open World. These Manager controls use the
application theme.

## 4. Use one theme contract

**Principle:** [Principle 4: Shared recipes and theme rules](principles.md#4-interface-controls-must-use-shared-recipes-themes-change-appearance-while-preserving-purpose-and-behavior).

Each theme Package supplies mappings for element properties according to Usage
and State through an ordinary **Godot Theme** resource and includes any additional
visual assets.
Material resources supply the actual fonts, colors, textures, dimensions,
borders, shadows, and other design values.
Built-in themes follow the same contract. Package screens use shared theme
properties through the public UI Kit.

## 5. Apply the selected theme across the World

**Principles:** [Principle 3: Distinct interfaces within one design system](principles.md#3-world-building-running-a-game-and-playing-must-have-distinct-interfaces-within-one-design-system),
[Principle 4: Shared recipes and theme rules](principles.md#4-interface-controls-must-use-shared-recipes-themes-change-appearance-while-preserving-purpose-and-behavior).

Apply the World's selected theme to the game interface, Builder tools, and
Package screens. Keep each workspace's layout and behavior. Keep the Manager's
application theme separate.

Give participant accessibility preferences priority over theme values.
Use a built-in theme as the fallback.

## Details to define

- Package declaration, supported properties, and compatibility rules.
- When theme changes take effect.
- Fallback rules for missing theme data or unavailable Packages.
- Supported accessibility preferences.