extends Node

func _ready() -> void:
	GodotLogger._set_loglevel("info")

var is_transitioning : bool = false
func transition_to_scene(scene_path : String) -> void:
	if is_transitioning:
		return
	is_transitioning = true
	Transition.transition()
	await Transition.on_transition_finished
	get_tree().change_scene_to_file(scene_path)
	is_transitioning = false
