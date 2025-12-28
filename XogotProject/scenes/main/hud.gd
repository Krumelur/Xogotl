# Hud's processing is set to "Always" in Inspector.
# This allow tracking touch input even when game is paused.
class_name Hud
extends Node2D

@onready var game_over_root : Node2D = $GameOverRoot

func hide_game_over() -> void:
	game_over_root.visible = false

func show_game_over(reason : String) -> void:
	game_over_root.visible = true
	$GameOverRoot/Reason.text = reason

func update_energy(energy : float) -> void:
	var rect_max = $EnergyMax
	var rect = $EnergyMax/EnergyCurrent
	var label = $EnergyMax/Text
	
	rect.size.x = energy * rect_max.size.x
	label.text = "Energy\n%d%%" % int(round(energy * 100))


func update_score(score : int) -> void:
	$Score.text = "Score\n%d" % score


func update_limbs(num_limbs : int, grow_progress : float) -> void:
	var rect_max = $LimbsProgressMax
	var rect = $LimbsProgressMax/LimbsProgressCurrent
	var label = $LimbsProgressMax/Text
	
	rect.size.x = grow_progress * rect_max.size.x
	label.text = "Limbs\n%d" % num_limbs
	
func _unhandled_input(event: InputEvent) -> void:
	var touch : InputEventScreenTouch = event as InputEventScreenTouch
	if touch:
		if game_over_root.visible:
			get_tree().paused = false
			await global.transition_to_scene("res://scenes/main/game_main.tscn")
			hide_game_over()
			
			
