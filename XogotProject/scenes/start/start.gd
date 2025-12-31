class_name Start
extends Node2D

@export var scroller_speed : float = 40
@onready var instructions_label : Label = $Instructions
@onready var version_label : Label = $Version
@onready var tap_to_start_label : Label = $TapToStart
@onready var hiscore_label : Label = $HiScore
@onready var fx_start : AudioStreamPlayer = $FX/Start
@onready var fx_music : AudioStreamPlayer = $FX/Music


var scroller_start_pos_X : float

func _ready() -> void:
	fx_music.play()
	scroller_start_pos_X = instructions_label.position.x
	version_label.text = "v%s" % ProjectSettings.get_setting("application/config/version")
	var start_tween = create_tween()
	start_tween.tween_property(tap_to_start_label, "self_modulate:a", 1.0, 0.5)
	start_tween.tween_property(tap_to_start_label, "self_modulate:a", 0.3, 0.5)
	start_tween.set_loops()
	start_tween.play()
	
	var hiscore_json : Variant = global.load_json("user://state/hiscore.json")
	if hiscore_json:
		hiscore_label.text = "Hiscore: %s" % int(hiscore_json["score"])
	else:
		hiscore_label.text = "Hiscore: 0"

func _process(delta: float) -> void:
	instructions_label.position.x -= delta * scroller_speed
	if instructions_label.position.x < -instructions_label.size.x:
		instructions_label.position.x = scroller_start_pos_X

func _unhandled_input(event: InputEvent) -> void:
	var touch : InputEventScreenTouch = event as InputEventScreenTouch
	if touch:
		fx_start.play()
		await global.transition_to_scene("res://scenes/main/game_main.tscn")
		await fx_start.finished
