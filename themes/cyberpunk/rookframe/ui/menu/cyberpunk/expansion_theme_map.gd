extends RefCounted
## Optional semantic mappings; concrete values stay in Materials.
## Labels read RookframeTokens values: each role's size, the running-text face
## (the meta face for meta-size labels) and the content ink.
const ELEMENTS = {
	"RookframeTitle": {"base_type": &"Label", "fonts/font": "token.fonts.body", "font_sizes/font_size": "token.font_sizes.display", "colors/font_color": "token.colors.content"},
	"RookframeSubtitle": {"base_type": &"Label", "fonts/font": "token.fonts.body", "font_sizes/font_size": "token.font_sizes.title", "colors/font_color": "token.colors.content"},
	"RookframeValue": {"base_type": &"Label", "fonts/font": "token.fonts.body", "font_sizes/font_size": "token.font_sizes.value", "colors/font_color": "token.colors.content"},
	"RookframeHeading": {"base_type": &"Label", "fonts/font": "token.fonts.body", "font_sizes/font_size": "token.font_sizes.heading", "colors/font_color": "token.colors.content"},
	"RookframeIdentity": {"base_type": &"Label", "fonts/font": "token.fonts.body", "font_sizes/font_size": "token.font_sizes.body", "colors/font_color": "token.colors.content"},
	"RookframeBody": {"base_type": &"Label", "fonts/font": "token.fonts.body", "font_sizes/font_size": "token.font_sizes.body", "colors/font_color": "token.colors.content"},
	"RookframeLabel": {"base_type": &"Label", "fonts/font": "token.fonts.body", "font_sizes/font_size": "token.font_sizes.label", "colors/font_color": "token.colors.content"},
	"RookframeMeta": {"base_type": &"Label", "fonts/font": "token.fonts.meta", "font_sizes/font_size": "token.font_sizes.meta", "colors/font_color": "token.colors.content"},
	"RookframeStatus": {"base_type": &"Label", "fonts/font": "token.fonts.meta", "font_sizes/font_size": "token.font_sizes.meta", "colors/font_color": "token.colors.content"},
	"RookframePending": {"base_type": &"Label", "fonts/font": "token.fonts.meta", "font_sizes/font_size": "token.font_sizes.meta", "colors/font_color": "token.colors.content"},
	"RookframeSuccess": {"base_type": &"Label", "fonts/font": "token.fonts.meta", "font_sizes/font_size": "token.font_sizes.meta", "colors/font_color": "token.colors.content"},
	"RookframeError": {"base_type": &"Label", "fonts/font": "token.fonts.meta", "font_sizes/font_size": "token.font_sizes.meta", "colors/font_color": "token.colors.content"},
	"RookframeBadgeText": {"base_type": &"Label", "fonts/font": "token.fonts.meta", "font_sizes/font_size": "token.font_sizes.meta", "colors/font_color": "token.colors.content"},
	"RookframeRaisedSurface": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeBadge": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeInlineNoticeInfo": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeInlineNoticePending": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeInlineNoticeSuccess": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeInlineNoticeError": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeChoiceRow": {"base_type": &"editor.button.standard"},
	"RookframePopover": {"base_type": &"PopupPanel", "styles/panel": "editor.surface.inset"},
}
