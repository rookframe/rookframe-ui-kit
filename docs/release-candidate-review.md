# v1.0.0-rc.1 candidate review

This is the final manual coverage, boundary, provenance, and consumer review for
the mutable pre-user `v1.0.0-rc.1` candidate. It is evidence, not an automated
validation suite or scripted release gate.

## Candidate identity

The annotated Git tag `v1.0.0-rc.1` identifies the exact source commit under
review. Resolve it with `git rev-list -n 1 v1.0.0-rc.1`; consumers must put the
resulting full 40-character commit in gd-plug and in their authoring provenance
metadata. The owner may move this candidate tag while there are no external
users, but moving it never changes an existing exact-commit lock.

Stable `v1.0.0` is absent and remains an owner-controlled publication action.

## Normal Godot consumer proof

The proof used the pinned Godot 4.7 Mono editor at
`/Applications/Godot_mono.app/Contents/MacOS/Godot` and a fresh copy of
`examples/exact-commit-consumer`, not the repository project or its catalogue.

The checked-in declaration pins the complete candidate runtime-content commit
`1fe5bdb21d07dc06d407362eae4b3570cdcf16bf`. gd-plug reported that exact
commit, installed only `rookframe/ui`, and materialized 222 runtime files.
`examples/`, the full visual catalogue, root documentation, and repository
development material were absent from the installed subtree.

In the ordinary Godot editor, the materialized `rookframe` directory appeared
in the FileSystem dock. `consumer.tscn` opened with the installed shared Theme,
semantic icon, and public Search Field resolved at their canonical paths. The
scene demonstrates the normal author workflow:

- instance `search_field.tscn` as a `PackedScene`;
- configure its exported `show_label` and `placeholder` properties;
- apply the Theme and semantic variations to native Controls;
- connect the public `value_changed` and `cleared` signals through ordinary
  scene connections; and
- run the authored scene without repository-specific tooling.

During local candidate preparation, the unpublished content and tagged commits
were materialized through gd-plug from this repository's local Git URL; the
public GitHub URL had already been proved at its preceding exact commit. After
the commit and candidate tag are pushed by the owner, the checked-in declaration
fetches the same content commit from GitHub. No push or external release
publication is performed by this ticket.

The final tagged commit changes only repository documentation and the consumer
declaration after the content commit above, so its installed `rookframe/ui`
tree is byte-identical. The same clean materialization and open/run check was
repeated against the exact commit named by the `v1.0.0-rc.1` tag.

## Public-reference coverage

The manual reference review found:

- all 39 public Theme variations documented by name, native base type,
  semantic purpose, and native composition rule;
- all 62 semantic icons documented by public path, import UID, purpose,
  accessible-label expectation, composition rule, and pinned provenance;
- all 23 public component scenes documented by path, scene UID, script UID,
  root type, properties and defaults, signals, methods, slots, states or
  variants, behavior, focus/input behavior, and accessibility expectations;
- the public `RookframeManagedSurfaceState` Resource documented with the same
  identity and API detail; and
- every public font, frame, Theme, token, manifest, and catalogue identity
  documented with its purpose and composition guidance.

The runtime `catalogue.json` remains the machine-readable API index. The
human-readable references explain composition and accessibility without making
internal child-node structure public.

## Design-system coverage review

`docs/design-system-coverage.md` remains the approved source inventory and
`docs/rfg-161-coverage.md` maps every role assigned to implementation. The
final comparison found no role classified **Native + Theme** without Theme or
recipe coverage and no **Kit relationship** without a public scene or an
explicit native composition. Every important variation, icon, component,
responsive profile, and supported semantic state appears in the complete root
visual catalogue.

Application-specific classifications remain exclusions rather than missing UI
Kit work.

## Installed-boundary review

The final path and source review of `rookframe/ui` found:

- no application screen, route, finished feature workflow, or domain-state
  owner;
- no host registry, Package adapter, persistence backend, ownership policy, or
  placement orchestration;
- no consumer-named duplicate icon or style;
- no pass-through wrapper for an adequate native Button, input, list, tree,
  tab, menu, popup, window, grid, separator, image, or progress control;
- no C# source or public widget hierarchy; and
- no example, visual catalogue, repository tool, release script, test suite,
  or other development-only material.

The only unsupported runtime path is `rookframe/ui/_internal/`. The current
directory contains only its boundary README; any future private helper must
remain beneath it.

## License and attribution review

Rookframe-owned source, scenes, documentation, frame renderings, and other
assets are covered by the root MIT license. The public icon subset is pinned to
Tabler Icons 3.46.0 commit
`8ac7d81b72ece11072ef25ea9fd92e80c6f3c9fc` with its MIT text and per-icon
mapping. Exo 2 and Inter retain their SIL Open Font License 1.1 texts and
documented SHA-256 hashes. The development-only gd-plug consumer retains its
MIT license and exact upstream revision.

No legacy shell atlas, sample portrait, unrelated brand art, external domain
pictogram, or asset with unclear or incompatible provenance is present.
