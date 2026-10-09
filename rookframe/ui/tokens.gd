class_name RookframeUiTokens
extends RefCounted

## Shared semantic values for public Rookframe UI Kit scenes and scripts.
##
## Package scenes should prefer Theme variations. These constants are for
## reusable relationships whose layout or state cannot be expressed by a Theme
## item alone. Exact visual values may change compatibly while their semantic
## purposes remain stable.

const COLOR_CANVAS := Color("#151719")
const COLOR_SURFACE := Color("#23282b")
const COLOR_SURFACE_RAISED := Color("#343d41")
const COLOR_SURFACE_SUNKEN := Color("#151719")
const COLOR_SURFACE_HOVER := Color("#343d41")
const COLOR_SURFACE_ACTIVE := Color("#ceccb3")
const COLOR_INK := Color("#151719")
const COLOR_EDGE := Color("#5b6265")
const COLOR_RULE := Color("#3e4346")
const COLOR_CONTENT := Color("#e7e7dd")
const COLOR_CONTENT_MUTED := Color("#aebabe")
const COLOR_ACCENT := Color("#ceccb3")
const COLOR_ACCENT_BRIGHT := Color("#e7e7dd")
const COLOR_HIERARCHY := Color("#e7e7dd")
const COLOR_SUCCESS := Color("#a9c4b6")
const COLOR_DANGER := Color("#ff817a")
const COLOR_DISABLED := Color("#aebabe")

const SPACE_1 := 4
const SPACE_2 := 8
const SPACE_3 := 12
const SPACE_4 := 16
const SPACE_5 := 24
const SPACE_6 := 32
const SPACE_7 := 48
const SPACE_8 := 64

const MINIMUM_TARGET_SIZE := 44
const PRIMARY_ACTION_HEIGHT := 52
const ICON_SIZE := 24
const FOCUS_WIDTH := 2
const BORDER_WIDTH := 1
const RADIUS_SMALL := 0
const RADIUS_MEDIUM := 0
const FRAME_CUT := 0

const TYPE_TITLE := 40
const TYPE_SUBTITLE := 30
const TYPE_HEADING := 24
const TYPE_LABEL := 20
const TYPE_VALUE := 30
const TYPE_BODY := 21
const TYPE_META := 18
const TYPE_STATUS := 18
const TYPE_IDENTITY := 22
const TYPE_INPUT := 20
const TYPE_ACTION := 20
const TYPE_BADGE := 18

const LINE_TITLE := 48
const LINE_SUBTITLE := 38
const LINE_HEADING := 30
const LINE_LABEL := 26
const LINE_VALUE := 36
const LINE_BODY := 29
const LINE_META := 24
const LINE_STATUS := 24
const LINE_IDENTITY := 28
const LINE_INPUT := 26
const LINE_ACTION := 26
const LINE_BADGE := 24

const TEXTAREA_MINIMUM_HEIGHT := 112
const RESPONSIVE_TWO_REGION_WIDTH := 720
const RESPONSIVE_TOOLBAR_WIDTH := 700
const RESPONSIVE_RECORD_WIDTH := 620
const RESPONSIVE_ACTION_BAR_WIDTH := 560
const ADAPTIVE_GRID_MINIMUM_CELL_WIDTH := 220
const METRIC_MINIMUM_CELL_WIDTH := 160
const MEDIA_PREVIEW_SIZE := 160
const INITIAL_DOCK_WIDTH := 560
const MANAGED_SURFACE_MINIMUM_WIDTH := 360
const MANAGED_SURFACE_MINIMUM_HEIGHT := 420

## Independent decorative roles; functional state colors take precedence.
const COLOR_RIBBON := Color("#bd5b68")
const COLOR_LEDGER_RULE := Color("#bc9277")
const COLOR_PICTOGRAM := Color("#d0be8e")
const COLOR_SECTION_COUNT := Color("#d9ae94")
const COLOR_ORNAMENT := Color("#bc9277")
const LEDGER_RULE_WIDTH := 6
