# Public components

These public resources are the entry points for Rookframe UI, including thin
proxies for standard Godot controls and resources. Proxies keep native behavior;
composed components add relationships that Godot does not provide as one node.
See [the proxy paths and usage contract](../../../docs/native-controls-and-recipes.md#public-native-proxies).

- `layout/` contains adaptive grids and splits, task hierarchy, compact route
  headings, sections, action groups, and toolbars.
- `actions/` contains native buttons, toggles, action containers and toggle groups;
  `navigation/` contains retained native tabs.
- `forms/` contains labelled field relationships, one-perimeter search,
  one Choice with row, card, marked and list presentations, and neutral
  media replacement.
- `feedback/` contains in-task Notice, Task State, and Step Progress regions.
- `data/` contains metrics, badges, compact key/value and compact/detailed
  Package records, compact action rows and inline action links, roll/result
  rows, icon-action grids, and the context-neutral Structured Row family.
- `surfaces/` contains the retained Managed Surface relationship and its
  serializable semantic state.

The supported properties, defaults, signals, methods, slots, states, variants,
paths, and UIDs are documented in
[the public component reference](https://github.com/rookframe/rookframe-ui-kit/blob/next/ui-kit/docs/public-components.md)
and indexed by
[`rookframe/ui/catalogue.json`](../catalogue.json).

The wizard frame accepts an optional primary-action Texture2D in `set_primary`;
the consumer chooses its meaning. Step indexes only control progress styling.
