
class_name FishBone
extends PondInhabitant

const DROP_SPEED : float = 10
const WOBBLE_STRENGTH : float = 4
const WOBBLE_DURATION : float = 1.5
# Chance that instead of a fishbone a valuable gift is dropped.
const IS_GIFT_CHANCE : float = 0.25

var wobble_tween : Tween
var is_sinking : bool = false

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D


func get_inhabitant_type() -> INHABITANT_TYPE:
	if sprite.animation == "gift":
		return INHABITANT_TYPE.GIFT
	else:
		return INHABITANT_TYPE.FISH_BONE


func _ready() -> void:
	wobble_tween = create_tween()
	wobble_tween.tween_property(self, "position:x", WOBBLE_STRENGTH, WOBBLE_DURATION).as_relative()
	wobble_tween.tween_property(self, "position:x", -WOBBLE_STRENGTH, WOBBLE_DURATION).as_relative()
	wobble_tween.set_loops(0)
	wobble_tween.play()
	
	# Make fish look left or right randomly.
	scale.x = -1.0 if randi_range(0, 1) == 0 else 1.0
	
	await throw_over_board()
	is_sinking = true
	

func _process(delta: float) -> void:
	if is_sinking:
		position.y += delta * DROP_SPEED
	
	if global_position.y > 200:
		remove_from_pond()


func throw_over_board() -> void:
	if randf() >= 1.0 - IS_GIFT_CHANCE:
		sprite.animation = "gift"
	else:
		sprite.animation = "default"
	var tween = create_tween()
	tween.tween_property(self, "position:y", -10, 0.35).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position:y", 30, 0.65).as_relative().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.play()
	await tween.finished
