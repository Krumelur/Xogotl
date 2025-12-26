class_name Eel
extends PondInhabitant

const MIN_SPEED : float = 13
const MAX_SPEED : float = 20
const MIN_Y : int = 40
const MAX_Y : int = 170

var direction : int = 0
var speed : float = MIN_SPEED

@onready var eel_sprite = $EelSprite
@onready var electric_sprite = $ElectricSprite

func get_inhabitant_type() -> INHABITANT_TYPE:
	return INHABITANT_TYPE.EEL


func _ready() -> void:
	initialize()
	
func initialize() -> void:
	speed = randf_range(MIN_SPEED, MAX_SPEED)
	position.y = randi_range(MIN_Y, MAX_Y)
	
	if randi_range(0, 1) == 0:
		GodotLogger.info("Eel is going left at Y", position.y)
		position.x = 180 + randi_range(0, 40)
		direction = -1
		eel_sprite.flip_h = false
		electric_sprite.flip_h = false
	else:
		GodotLogger.info("Eel is going right at Y", position.y)
		position.x = -32 - randi_range(0, 40)
		direction = 1
		eel_sprite.flip_h = true
		electric_sprite.flip_h = true

func _process(delta: float) -> void:
	position.x += speed * delta * direction
	
	if direction == -1 and position.x < -31:
		remove_from_pond()
	elif direction == 1 and position.x >= 210:
		remove_from_pond()
		
