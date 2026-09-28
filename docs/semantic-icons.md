# Semantic icon reference

Each SVG below is a public resource identity. Choose the semantic name, not
the upstream drawing name or the name of a consuming screen. The purpose
column is also the default accessible label when the icon is used alone.

Load the SVG as an ordinary `Texture2D` and assign it to a native `Button`,
`TextureRect`, list item, tree item, or documented component property:

```gdscript
var retry_icon := load("res://rookframe/ui/icons/retry.svg")
```

Use a 24px visual inside an interaction target of at least 44×44px. An
icon-only action needs an `accessibility_name` and matching tooltip that name
the action in context. Native Buttons use their Theme icon colors; TextureRects may use
`CanvasItem.modulate`. Do not edit or copy
the SVG to create consumer-named color variants. Decorative icons must not be
the only carrier of status or meaning.

`rookframe/ui/icons/manifest.json` records the same ordered registry plus the
pinned Tabler source name and license provenance.

| Semantic name and path | Resource UID | Purpose / default accessible label |
| --- | --- | --- |
| `add.svg` | `uid://0y15uki56wjy` | Add |
| `remove.svg` | `uid://can7cade7k1lg` | Remove |
| `edit.svg` | `uid://lo5ceypo1jm3` | Edit |
| `search.svg` | `uid://40hn1qbnn56` | Search |
| `clear.svg` | `uid://dibqij4bjn2gs` | Clear |
| `close.svg` | `uid://d3jlevfiv21qt` | Close |
| `person.svg` | `uid://bag2nnuqvqfao` | Person |
| `people.svg` | `uid://cr3t0042ht85o` | People |
| `person-add.svg` | `uid://cxk3jm0xe2li2` | Add person |
| `chevron.svg` | `uid://bmfihj8c8kkil` | Expand |
| `chevron-right.svg` | `uid://r1oh2eyq5n5w` | Open |
| `chevron-up.svg` | `uid://cvlco5r52dnqu` | Collapse |
| `chevron-left.svg` | `uid://dfcaqacwprak2` | Previous |
| `info.svg` | `uid://be6bdeisqkh7e` | Information |
| `warning.svg` | `uid://dqipo7vi5b4rn` | Warning |
| `error.svg` | `uid://cnexc6kt4wwrk` | Error |
| `rook.svg` | `uid://ct1qg4a81bchf` | Actor definitions |
| `bolt.svg` | `uid://bpogg5i4icpxq` | Special rule |
| `folder.svg` | `uid://dl5plxtufj4xn` | Folder |
| `document.svg` | `uid://cli0u1nbkdts8` | Document |
| `shield.svg` | `uid://qi48luvpw1ao` | Armor |
| `swords.svg` | `uid://bqookr128shgw` | Weapons |
| `sigil.svg` | `uid://budrq68fngtc4` | Powers |
| `pack.svg` | `uid://b4tdtksikdtdq` | Gear |
| `check.svg` | `uid://c124tkbxcjxhl` | Complete |
| `spinner.svg` | `uid://cu1jhlh1cmjls` | Pending |
| `list.svg` | `uid://4py4osjfhken` | List |
| `copy.svg` | `uid://dagbu436kdxh7` | Copy |
| `delete.svg` | `uid://d180ytrhnbhgu` | Delete |
| `rotate.svg` | `uid://bv74i27rnqg0b` | Rotate |
| `retry.svg` | `uid://dpyppyv8nobib` | Retry |
| `settings.svg` | `uid://dp27gmw0xucgf` | Settings |
| `lock.svg` | `uid://cr2kirnybk6vq` | Locked |
| `unlock.svg` | `uid://caoxl3h0axkdg` | Unlocked |
| `upload.svg` | `uid://ct0x11tdlbecr` | Upload |
| `download.svg` | `uid://c03sp7v6sasl6` | Download |
| `pop-out.svg` | `uid://due5sofa3mug4` | Pop out |
| `dock.svg` | `uid://g1rnxw3f1l4q` | Dock |
| `minimize.svg` | `uid://b1ytml712a1q4` | Minimize |
| `restore.svg` | `uid://cfdmwbtob3hoe` | Restore |
| `drag.svg` | `uid://b8oxlciwhud05` | Drag |
| `compass.svg` | `uid://c0coktvjkw618` | Compass |
| `crosshair.svg` | `uid://c2aif2nwlrbln` | Grid |
| `eye.svg` | `uid://do3fhuhfsm0sp` | Vision |
| `layers.svg` | `uid://dycicfvnbfiwl` | Layers |
| `ruler.svg` | `uid://dnppbowi3e58h` | Ruler |
| `speaker.svg` | `uid://cmo0rxgpem6cn` | Audio |
| `dice.svg` | `uid://c157r0i7ct3eg` | Dice |
| `filter.svg` | `uid://buag2cgev6uri` | Filter |
| `menu.svg` | `uid://d88a4v0tdgn2` | Menu |
| `help.svg` | `uid://di8g7kujro2py` | Help |
| `link.svg` | `uid://lrdlsx1nxj1a` | Link |
| `save.svg` | `uid://bc3xj085ollie` | Save |
| `home.svg` | `uid://bt1cnr267b8nh` | Home |
| `world.svg` | `uid://p23al82r7l54` | World |
| `back.svg` | `uid://dnf5do7qcsvhl` | Back |
| `forward.svg` | `uid://fn8f2vfnpxqn` | Forward |
| `builder.svg` | `uid://bs7lma7rhkmlq` | Builder Mode |
| `region-rectangle.svg` | `uid://brrwvwgqi5fxr` | Rectangle Region tool |
| `region-circle.svg` | `uid://bmxcu2qrnbm42` | Circle Region tool |
| `region-ellipse.svg` | `uid://cfd6wqe8dwm7t` | Ellipse Region tool |
| `region-polygon.svg` | `uid://cvtthuykofiaw` | Polygon Region tool |
| `region-free-form.svg` | `uid://dr8frgswqv7q7` | Free-form Region tool |
| `collision.svg` | `uid://c2oytsj410jy4` | Collision |
| `light-on.svg` | `uid://dl48x0w43v6ev` | Light on |
| `light-off.svg` | `uid://bjgirs1syk7e5` | Light off |

Collision uses Tabler **barrier-block**; light-on and light-off use **bulb**
and **bulb-off** from the same pinned 3.46.0 source. Delete keeps `delete.svg`
(trash). Light textures are available for working light capabilities; ordinary
Props must not expose a placeholder light action.

For collision toggles, compose a native Button with `toggle_mode`, a centered
24px icon and a 44×44 minimum target. Update `set_pressed_no_signal()` from the
accepted state and give `accessibility_name` and `tooltip_text` the same
contextual label, for example “Toggle collision, currently on”. The existing
`RookframeManagedControl` and `RookframeDangerOutline` roles tint native icons
with their established text colors, including focus, pressed and disabled states.

## Illustrated RPG selection

Game-icons.net is a supported supplemental source. These curated, public
Texture2D resources appear alongside semantic actions in the Icons catalogue,
under `domainPictograms` in the same manifest. They remain outside the general
Tabler action registry. Use them in a narrowly scoped, authored domain UI (for
example an item illustration or spell selector) using ordinary TextureRects
or native Button icons; do not replace navigation, collision, light or delete
roles with them. No additional icon loader or component framework is required.

Use `expand_mode = EXPAND_IGNORE_SIZE` and `STRETCH_KEEP_ASPECT_CENTERED` on a
TextureRect; for a Button, set `icon_max_width` to the desired visual size.
The original artwork is 512×512. Retain attribution when distributing it.

| Public path (under `res://rookframe/ui/icons/`) | Resource UID | Author / source |
| --- | --- | --- |
| `game-icons/broadsword.svg` | `uid://ch2nkllltcpwr` | [Broadsword — Lorc](https://game-icons.net/1x1/lorc/broadsword.html) |
| `game-icons/fairy-wand.svg` | `uid://baat32b4wg2af` | [Fairy wand — Lorc](https://game-icons.net/1x1/lorc/fairy-wand.html) |
| `game-icons/fireball.svg` | `uid://yvjjjviqbcy1` | [Fireball — Lorc](https://game-icons.net/1x1/lorc/fireball.html) |
| `game-icons/spell-book.svg` | `uid://7dhicqd2u0wm` | [Spell book — Delapouite](https://game-icons.net/1x1/delapouite/spell-book.html) |
| `game-icons/beer-stein.svg` | `uid://d0mi35pujsr22` | [Beer stein — Lorc](https://game-icons.net/1x1/lorc/beer-stein.html) |
| `game-icons/spiral-tentacle.svg` | `uid://ctgofbh0ualhw` | [Spiral tentacle — Lorc](https://game-icons.net/1x1/lorc/spiral-tentacle.html) |
| `game-icons/evil-book.svg` | `uid://cwcbpnwnc14jx` | [Evil book — Lorc](https://game-icons.net/1x1/lorc/evil-book.html) |

All seven use [CC BY 3.0](https://creativecommons.org/licenses/by/3.0/).
The installed [attribution](../rookframe/ui/icons/game-icons/ATTRIBUTION.md)
and manifest retain titles, authors, source/download URLs, changes and hashes.

Rotation uses the pinned Tabler **rotate** glyph. Compose a centered 24px icon
in a native toggle Button with at least a 44px target. Name its context through
the tooltip and accessible name, for example "Show Prop rotation controls" or
"Hide Prop rotation controls". The consuming application owns the spatial
interaction; this asset supplies only the semantic rotation affordance.
