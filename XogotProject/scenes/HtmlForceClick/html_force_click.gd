extends Control

@onready var tap_to_start_label : Label = $Border/TapToStart

func _ready() -> void:
	var os_name = OS.get_name().to_lower()
	GodotLogger.info("OS", os_name)
	# Web export requires user input to play music or sound so we need this dummy screen.
	if os_name != "web":
		get_tree().change_scene_to_file("res://scenes/start/start.tscn")
		return
		
	var start_tween = create_tween()
	start_tween.tween_property(tap_to_start_label, "self_modulate:a", 1.0, 0.5)
	start_tween.tween_property(tap_to_start_label, "self_modulate:a", 0.3, 0.5)
	start_tween.set_loops()
	start_tween.play()
	

func _unhandled_input(event: InputEvent) -> void:
	var touch : InputEventScreenTouch = event as InputEventScreenTouch
	if touch:
		global.transition_to_scene("res://scenes/start/start.tscn")
