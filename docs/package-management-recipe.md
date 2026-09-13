# Exact-release management recipe

Compose Package management from the existing Theme and authored native Controls.
The application owns release data, acquisition, selection and recovery. This
recipe adds no public widget or Package lifecycle service to the UI Kit.

Use a `VBoxContainer` inside a scrolling managed task. Keep the required System
and independent optional choices visible first. An **Installed releases & recovery**
disclosure contains a public Manifest `LineEdit`, acquisition actions, readable
progress, cancel/retry, storage totals, and exact-release cards. An installation
library can use this same content before a World exists.

Each card is an authored `PanelContainer` with `RookframeRaisedSurface`, 16 px
margins and a vertical content stack. Show name/version, Kind and ID, ordinary
summary, installed/missing state, enabled state in the selected World and affected
local Worlds. Use `RookframeHeading`, `RookframeBody` and `RookframeMeta` according
to hierarchy. Identity, metadata and compatibility are text; they do not imply
security approval or a safety badge.

Use an `HFlowContainer` for independent actions. Native buttons keep at least
44 px height, keyboard focus and accessible names. Use `RookframeQuietButton`
for ordinary choices and the existing danger variation for deletion. Long IDs,
source errors, affected World names and storage descriptions wrap. Dialogs fit
the phone canvas and keep their native cancel/confirm actions reachable.

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
