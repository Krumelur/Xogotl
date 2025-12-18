class_name GameMain

extends Node2D

@onready var waves_root : Node2D = $WavesRoot
@onready var hud : Hud = $CanvasLayerHud/HudRoot

const WAVES_AMPLITUDE : int = 1
const WAVES_SPEED : float = 3

func _ready() -> void:
	var waves_tween = create_tween()
	waves_tween.set_loops(0)
	var waves_start_y := waves_root.position.y
	waves_tween.tween_property(waves_root, "position:y", waves_start_y - WAVES_AMPLITUDE, WAVES_SPEED)
	waves_tween.tween_property(waves_root, "position:y", waves_start_y + WAVES_AMPLITUDE, WAVES_SPEED)
	waves_tween.play()
	
