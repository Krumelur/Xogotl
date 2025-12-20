class_name GameMain

extends Node2D

@onready var waves_root : Node2D = $Playfield/WavesRoot
@onready var hud : Hud = $CanvasLayerHud/HudRoot

var energy : int = 100 : 
	set(value):
		GodotLogger.info("Energy", value)
		energy = value
		hud.update_energy(energy)
	
var score : int = 0:
	set(value):
		GodotLogger.info("Score", value)
		score = value
		hud.update_score(score)

const WAVES_AMPLITUDE : int = 1
const WAVES_SPEED : float = 3



func _ready() -> void:
	var waves_tween = create_tween()
	waves_tween.set_loops(0)
	var waves_start_y := waves_root.position.y
	waves_tween.tween_property(waves_root, "position:y", waves_start_y - WAVES_AMPLITUDE, WAVES_SPEED)
	waves_tween.tween_property(waves_root, "position:y", waves_start_y + WAVES_AMPLITUDE, WAVES_SPEED)
	waves_tween.play()


func _on_xogotl_has_eaten_inhabitant(inhabitant: PondInhabitant) -> void:
	var type : PondInhabitant.INHABITANT_TYPE = inhabitant.get_inhabitant_type()
	match type:
		PondInhabitant.INHABITANT_TYPE.FISH_BONE:
			inhabitant.remove_from_pond()
			score += 5
