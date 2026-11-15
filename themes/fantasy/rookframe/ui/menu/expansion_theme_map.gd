extends RefCounted
## Optional semantic mappings; concrete values stay in Materials.
## Type variations take their face, size and ink from Fantasy tokens (`token.*`).
const ELEMENTS = {
	"RookframeTitle": {"base_type": &"Label", "fonts/font": "token.font.display", "font_sizes/font_size": "token.font_size.display", "colors/font_color": "token.color.content"},
	"RookframeSubtitle": {"base_type": &"Label", "fonts/font": "token.font.title", "font_sizes/font_size": "token.font_size.title", "colors/font_color": "token.color.content"},
	"RookframeValue": {"base_type": &"Label", "fonts/font": "token.font.value", "font_sizes/font_size": "token.font_size.value", "colors/font_color": "token.color.content"},
	"RookframeHeading": {"base_type": &"Label", "fonts/font": "token.font.heading", "font_sizes/font_size": "token.font_size.heading", "colors/font_color": "token.color.content"},
	"RookframeIdentity": {"base_type": &"Label", "fonts/font": "token.font.heading", "font_sizes/font_size": "expansion.Identity.size", "colors/font_color": "token.color.content"},
	"RookframeBody": {"base_type": &"Label", "fonts/font": "token.font.body", "font_sizes/font_size": "token.font_size.body", "colors/font_color": "token.color.content"},
	"RookframeLabel": {"base_type": &"Label", "fonts/font": "token.font.label", "font_sizes/font_size": "token.font_size.label", "colors/font_color": "token.color.content"},
	"RookframeMeta": {"base_type": &"Label", "fonts/font": "token.font.meta", "font_sizes/font_size": "token.font_size.meta", "colors/font_color": "token.color.content"},
	"RookframeStatus": {"base_type": &"Label", "fonts/font": "token.font.meta", "font_sizes/font_size": "token.font_size.meta", "colors/font_color": "token.color.content"},
	"RookframePending": {"base_type": &"Label", "fonts/font": "token.font.meta", "font_sizes/font_size": "token.font_size.meta", "colors/font_color": "token.color.content"},
	"RookframeSuccess": {"base_type": &"Label", "fonts/font": "token.font.meta", "font_sizes/font_size": "token.font_size.meta", "colors/font_color": "token.color.content"},
	"RookframeError": {"base_type": &"Label", "fonts/font": "token.font.meta", "font_sizes/font_size": "token.font_size.meta", "colors/font_color": "token.color.content"},
	"RookframeBadgeText": {"base_type": &"Label", "fonts/font": "token.font.meta", "font_sizes/font_size": "token.font_size.meta", "colors/font_color": "token.color.content"},
	"RookframeRaisedSurface": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeBadge": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeInlineNoticeInfo": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeInlineNoticePending": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeInlineNoticeSuccess": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeInlineNoticeError": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeChoiceRow": {"base_type": &"editor.button.standard"},
	"RookframePopover": {"base_type": &"PopupPanel", "styles/panel": "editor.surface.inset"},
}
