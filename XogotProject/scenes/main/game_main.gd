class_name GameMain

extends Node2D

@onready var waves_root : Node2D = $Playfield/WavesRoot
@onready var hud : Hud = $CanvasLayerHud/HudRoot
@onready var xogotl : Xogotl = $Playfield/Xogotl
@onready var bubbles_root : Node2D = $Playfield/BubblesRoot
@onready var marker_bubbly_min_y : Marker2D = $Playfield/BubblesMinY

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

var bubble_scene : PackedScene
const MAX_BUBBLES : int = 3

func _ready() -> void:
	var waves_tween = create_tween()
	waves_tween.set_loops(0)
	var waves_start_y := waves_root.position.y
	waves_tween.tween_property(waves_root, "position:y", waves_start_y - WAVES_AMPLITUDE, WAVES_SPEED)
	waves_tween.tween_property(waves_root, "position:y", waves_start_y + WAVES_AMPLITUDE, WAVES_SPEED)
	waves_tween.play()
	
	bubble_scene = preload("res://scenes/xogotl/bubble.tscn")

func _process(delta: float) -> void:
	# If Xogotl is floating let him exhale bubbles.
	if xogotl.current_state == Xogotl.STATE.FLOAT:
		if bubbles_root.get_child_count() < MAX_BUBBLES:
			if randf() > 0.995:
				var bubble : Bubble = bubble_scene.instantiate()
				bubble.initialize(xogotl.global_position + Vector2(5 + randi_range(-5, +5), -15), $Playfield/BubblesMinY.global_position.y)
				bubbles_root.add_child(bubble)


func _on_xogotl_has_eaten_inhabitant(inhabitant: PondInhabitant) -> void:
	var type : PondInhabitant.INHABITANT_TYPE = inhabitant.get_inhabitant_type()
	match type:
		PondInhabitant.INHABITANT_TYPE.FISH_BONE:
			inhabitant.remove_from_pond()
			score += 5
