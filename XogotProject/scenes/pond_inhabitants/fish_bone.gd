class_name FishBone
extends PondInhabitant

const drop_speed : float = 10
const wobble_strength : float = 4
const wobble_duration : float = 1.5

var wobble_tween : Tween

func get_inhabitant_type() -> INHABITANT_TYPE:
	return INHABITANT_TYPE.FISH_BONE

func _ready() -> void:
	wobble_tween = create_tween()
	wobble_tween.tween_property(self, "position:x", wobble_strength, wobble_duration).as_relative()
	wobble_tween.tween_property(self, "position:x", -wobble_strength, wobble_duration).as_relative()
	wobble_tween.set_loops(0)
	wobble_tween.play()

func _physics_process(delta: float) -> void:
	position.y += delta * drop_speed

func _process(delta: float) -> void:
	if global_position.y > 200:
		remove_from_pond()
