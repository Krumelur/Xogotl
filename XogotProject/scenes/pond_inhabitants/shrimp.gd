class_name Shrimp
extends PondInhabitant

const wobble_strength : float = 2
const wobble_duration : float = 0.25
const MIN_DRIFT : float = -10.0
const MAX_DRIFT : float = 15.0
const MIN_X : float = 0
const MAX_X : float = 180
const MIN_Y : float = 50
const MAX_Y : float = 200


var wobble_tween : Tween
var direction : int = 0
var drift : float = 0
var speed : float = 4

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

func get_inhabitant_type() -> INHABITANT_TYPE:
	return INHABITANT_TYPE.SHRIMP

func initialize() -> void:
	direction = 1 if randi_range(0, 1) == 0 else -1
	sprite.flip_h = direction == 1
	
	drift = randf_range(MIN_DRIFT, MAX_DRIFT)
	position.x = randf_range(MIN_X, MAX_X)
	position.y = randf_range(MIN_Y, MAX_Y)

func _ready() -> void:
	wobble_tween = create_tween()
	wobble_tween.tween_property(sprite, "position:y", wobble_strength, wobble_duration).as_relative()
	wobble_tween.tween_property(sprite, "position:y", -wobble_strength, wobble_duration).as_relative()
	wobble_tween.set_loops(0)
	wobble_tween.play()
	
	initialize()
	

func _process(delta: float) -> void:
	position.x += speed * delta * direction
	position.y += drift * delta
	
	if position.x < 0 or position.x > 180:
		remove_from_pond()
		
	if position.y < MIN_Y or position.y > 200:
		remove_from_pond()
	
