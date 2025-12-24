class_name Eel
extends PondInhabitant

const SPEED : float = 13
const MIN_Y : int = 40
const MAX_Y : int = 170

var direction : int = 0

@onready var eel_sprite = $EelSprite
@onready var electric_sprite = $ElectricSprite

func get_inhabitant_type() -> INHABITANT_TYPE:
	return INHABITANT_TYPE.EEL


func _ready() -> void:
	initialize()
	
func initialize() -> void:
	position.y = randi_range(MIN_Y, MAX_Y)
	
	if randi_range(0, 1) == 0:
		GodotLogger.info("Eel is going left at Y", position.y)
		position.x = 180
		direction = -1
		eel_sprite.flip_h = false
		electric_sprite.flip_h = false
	else:
		GodotLogger.info("Eel is going right at Y", position.y)
		position.x = -32
		direction = 1
		eel_sprite.flip_h = true
		electric_sprite.flip_h = true

func _process(delta: float) -> void:
	position.x += SPEED * delta * direction
	
	if direction == -1 and position.x < -31:
		remove_from_pond()
	elif direction == 1 and position.x >= 210:
		remove_from_pond()
		
