class_name FishBone
extends PondInhabitant

const drop_speed : float = 10
const wobble_strength : float = 4
const wobble_duration : float = 1.5

var wobble_tween : Tween
var is_sinking : bool = false


func get_inhabitant_type() -> INHABITANT_TYPE:
	return INHABITANT_TYPE.FISH_BONE


func _ready() -> void:
	wobble_tween = create_tween()
	wobble_tween.tween_property(self, "position:x", wobble_strength, wobble_duration).as_relative()
	wobble_tween.tween_property(self, "position:x", -wobble_strength, wobble_duration).as_relative()
	wobble_tween.set_loops(0)
	wobble_tween.play()
	
	# Make fish look left or right randomly.
	scale.x = -1.0 if randi_range(0, 1) == 0 else 1.0
	
	await throw_over_board()
	is_sinking = true
	

func _process(delta: float) -> void:
	if is_sinking:
		position.y += delta * drop_speed
	
	if global_position.y > 200:
		remove_from_pond()


func throw_over_board() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:y", -20, 0.35).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", 30, 0.65).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.play()
	await tween.finished
