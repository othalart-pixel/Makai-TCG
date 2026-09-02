extends RefCounted

const CHARACTER_FRAME: Texture2D = preload("res://assets/ui/character_frame.png")
const TECHNIQUE_FRAME: Texture2D = preload("res://assets/ui/technique_frame.png")
const MISSION_FRAME: Texture2D = preload("res://assets/ui/mission_frame.png")
const CARD_BACK: Texture2D = preload("res://assets/ui/card_back.png")

static var horizontal_card_back: Texture2D = null


static func apply_to(button: Button, visual_type: String) -> void:
	var texture: Texture2D = TECHNIQUE_FRAME
	var top_margin: float = 132.0
	var side_margin: float = 16.0
	var bottom_margin: float = 10.0
	var font_size: int = 12

	match visual_type:
		"character":
			texture = CHARACTER_FRAME
			top_margin = 136.0
		"mission":
			texture = MISSION_FRAME
			top_margin = 48.0
			side_margin = 22.0
			bottom_margin = 18.0
			font_size = 13
		"hidden", "back":
			texture = CARD_BACK
			top_margin = 0.0
			side_margin = 0.0
			bottom_margin = 0.0
			font_size = 1
		"mission_back":
			texture = get_horizontal_card_back()
			top_margin = 0.0
			side_margin = 0.0
			bottom_margin = 0.0
			font_size = 1

	if button.custom_minimum_size.y < 180.0 and visual_type != "hidden" and visual_type != "back" and visual_type != "mission_back":
		side_margin = 8.0
		bottom_margin = 5.0
		font_size = 9 if visual_type == "mission" else 10
		top_margin = 24.0 if visual_type == "mission" else 48.0

	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = texture
	style.content_margin_left = side_margin
	style.content_margin_top = top_margin
	style.content_margin_right = side_margin
	style.content_margin_bottom = bottom_margin

	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		button.add_theme_stylebox_override(state, style)
	button.add_theme_color_override("font_color", Color(0.94, 0.96, 1.0))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color(0.84, 0.93, 1.0))
	button.add_theme_color_override("font_focus_color", Color.WHITE)
	button.add_theme_color_override("font_disabled_color", Color(0.62, 0.68, 0.75))
	button.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.95))
	button.add_theme_constant_override("shadow_offset_x", 1)
	button.add_theme_constant_override("shadow_offset_y", 2)
	button.add_theme_font_size_override("font_size", font_size)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


static func get_horizontal_card_back() -> Texture2D:
	if horizontal_card_back == null:
		var image: Image = CARD_BACK.get_image()
		image.rotate_90(CLOCKWISE)
		horizontal_card_back = ImageTexture.create_from_image(image)
	return horizontal_card_back


static func copy_to_preview(source: Button, preview: Button) -> void:
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style: StyleBox = source.get_theme_stylebox(state)
		if style != null:
			preview.add_theme_stylebox_override(state, style.duplicate())
	for color_name in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color", "font_shadow_color"]:
		preview.add_theme_color_override(color_name, source.get_theme_color(color_name))
	preview.add_theme_font_size_override("font_size", source.get_theme_font_size("font_size"))
	preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
