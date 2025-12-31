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

# /Users/<Username>/Library/Application Support/Godot/app_userdata/<ProjectName>/
func save_json(path : String, filename : String, data) -> void:
	var dir = DirAccess.open("user://")
	if not dir.dir_exists(path):
		dir.make_dir_recursive(path)
	
	var file = FileAccess.open("user://%s/%s" % [path, filename], FileAccess.WRITE)
	var json := JSON.stringify(data)
	file.store_string(json)
	file.flush()
	file.close()
	
	
	
func load_json(path : String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return null
	
	var json_string := file.get_as_text()
	file.close()
		
	var data : Variant = JSON.parse_string(json_string)
	if data == null:
		GodotLogger.error("Failed to load JSON from path", path)
	return data
