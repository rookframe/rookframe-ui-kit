# Exact-release management recipe

Compose Package management from the existing Theme and authored native Controls.
The application owns release data, acquisition, selection and recovery. This
recipe adds no public widget or Package lifecycle service to the UI Kit.

Start with a compact list: one disclosure row per Package identity, showing its
name, Kind and version (or version count). Reuse the same authored record-row
role as World Select. The Main Menu entry uses the same quiet, left-aligned
navigation row, trailing arrow and touch height as its World Select sibling.

Selecting a row opens a separate detail page. Show the exact version, ordinary
summary, installed/missing state, use in the selected World and affected local
Worlds. When multiple versions exist, use a version selector on this page.
Selection, enable/disable and update belong here. Repair and removal open their
own pages so routine inspection is not a wall of maintenance actions.

Installation is a separate task reached by **Install Package**. Offer local
archive import and a public Manifest link. Show a System compatibility selector
only when installation context needs a choice. Show progress/cancel during work
and Retry after a retryable outcome; hide idle progress controls. Storage has a
separate page with installed package files, ready-to-run files, pending cleanup and
in-use bytes. Explain that in-use bytes are included in the totals.

Compose these pages with authored `VBoxContainer`, `Label`, `OptionButton`,
`LineEdit` and the existing Theme button roles. Identity and metadata are text,
not approval badges. Native buttons keep at least 44 px touch height, keyboard
focus and accessible names. Use `RookframeQuietButton` for ordinary choices and
the existing danger variation for deletion. Long names and outcomes wrap.
Dialogs fit the phone canvas. Back returns to the previous package page before
leaving Package management. A fixed action divider appears only when its action
dock is present; it must never cross the scrolling page content.

| Action | Review content owned by the application |
| --- | --- |
| Replace an occupied ID/version | Exact release, available Catalogue Publisher, affected Worlds, retained data/settings and installation-wide effect |
| Update All | One complete proposal, old/new versions and retained enabled states; confirm once |
| Delete from World | Explicit permanent loss of Package World data/settings; installed files and User settings remain |
| Uninstall | Exact release and all blocking local selections, including disabled entries |

Errors identify acquisition, security/unsupported analysis, mapping, required
compatibility, advisory compatibility, settings or actual activation as appropriate.
State the exact release/profile when known, committed consequence and available
recovery. Preserve a general host failure when Package causation was not established.

Review the same task at desktop 1920 × 1080, phone 390 × 844 and tablet 1024 × 768
using the application's canonical authority. The phone changes composition and
scrolling, never the release, recovery or confirmation semantics.
