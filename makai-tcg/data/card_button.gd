extends Button

const CardVisualsScript = preload("res://data/card_visuals.gd")

var drag_enabled: bool = false
var drag_payload: Dictionary = {}
var hand_hovered: bool = false


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_mouse_entered() -> void:
	if hand_hovered:
		return
	hand_hovered = true
	z_index = 100
	position.y -= 4.0


func _on_mouse_exited() -> void:
	if not hand_hovered:
		return
	hand_hovered = false
	z_index = 0
	position.y += 4.0


func configure_drag(enabled: bool, payload: Dictionary) -> void:
	drag_enabled = enabled
	drag_payload = payload
	autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func _get_drag_data(_at_position: Vector2):
	if not drag_enabled:
		return null

	var preview: Button = Button.new()
	preview.custom_minimum_size = custom_minimum_size
	preview.size = custom_minimum_size
	preview.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	preview.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	preview.text = text
	CardVisualsScript.copy_to_preview(self, preview)
	preview.modulate = Color(1.0, 1.0, 1.0, 0.8)
	set_drag_preview(preview)
	return drag_payload.duplicate(true)
