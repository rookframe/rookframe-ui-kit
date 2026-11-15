extends RefCounted
## Optional semantic mappings; concrete values stay in Materials.
## Labels read RookframeTokens values: each role's size and ink. Titles and
## headings take their role's display face; other labels the running-text face
## (the meta face for meta-size labels). Captions and metadata draw muted;
## success and error draw in their status color.
const ELEMENTS = {
	"RookframeTitle": {"base_type": &"Label", "fonts/font": "token.fonts.display", "font_sizes/font_size": "token.font_sizes.display", "colors/font_color": "token.colors.content"},
	"RookframeSubtitle": {"base_type": &"Label", "fonts/font": "token.fonts.title", "font_sizes/font_size": "token.font_sizes.title", "colors/font_color": "token.colors.content"},
	"RookframeValue": {"base_type": &"Label", "fonts/font": "token.fonts.body", "font_sizes/font_size": "token.font_sizes.value", "colors/font_color": "token.colors.content"},
	"RookframeHeading": {"base_type": &"Label", "fonts/font": "token.fonts.heading", "font_sizes/font_size": "token.font_sizes.heading", "colors/font_color": "token.colors.content"},
	"RookframeIdentity": {"base_type": &"Label", "fonts/font": "token.fonts.body", "font_sizes/font_size": "token.font_sizes.body", "colors/font_color": "token.colors.content"},
	"RookframeBody": {"base_type": &"Label", "fonts/font": "token.fonts.body", "font_sizes/font_size": "token.font_sizes.body", "colors/font_color": "token.colors.content"},
	"RookframeLabel": {"base_type": &"Label", "fonts/font": "token.fonts.body", "font_sizes/font_size": "token.font_sizes.label", "colors/font_color": "token.colors.content"},
	"RookframeMeta": {"base_type": &"Label", "fonts/font": "token.fonts.meta", "font_sizes/font_size": "token.font_sizes.meta", "colors/font_color": "token.colors.content_muted"},
	"RookframeStatus": {"base_type": &"Label", "fonts/font": "token.fonts.meta", "font_sizes/font_size": "token.font_sizes.meta", "colors/font_color": "token.colors.content_muted"},
	"RookframePending": {"base_type": &"Label", "fonts/font": "token.fonts.meta", "font_sizes/font_size": "token.font_sizes.meta", "colors/font_color": "token.colors.content_muted"},
	"RookframeSuccess": {"base_type": &"Label", "fonts/font": "token.fonts.meta", "font_sizes/font_size": "token.font_sizes.meta", "colors/font_color": "token.colors.success"},
	"RookframeError": {"base_type": &"Label", "fonts/font": "token.fonts.meta", "font_sizes/font_size": "token.font_sizes.meta", "colors/font_color": "token.colors.danger"},
	"RookframeBadgeText": {"base_type": &"Label", "fonts/font": "token.fonts.meta", "font_sizes/font_size": "token.font_sizes.meta", "colors/font_color": "token.colors.content_muted"},
	"RookframeRaisedSurface": {"base_type": &"PanelContainer", "styles/panel": "expansion.surface.raised"},
	"RookframeBadge": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeInlineNoticeInfo": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeInlineNoticePending": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeInlineNoticeSuccess": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeInlineNoticeError": {"base_type": &"PanelContainer", "styles/panel": "editor.surface.inset"},
	"RookframeChoiceRow": {"base_type": &"editor.button.standard"},
	"RookframePopover": {"base_type": &"PopupPanel", "styles/panel": "editor.surface.inset"},
}
