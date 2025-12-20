class_name Boat
extends Node2D

@onready var boat_sprite : Sprite2D = $BoatSprite

const SPEED : float = 4.0
const TARGET_X_MIN : int = 40
const TARGET_X_MAX : int = 145
const MIN_MOVE_DISTANCE = 20

var next_target_x : float = 0
var direction : int = 0

func _ready() -> void:
	set_next_target_x()
	position.x = TARGET_X_MIN


func set_next_target_x() -> void:
	# Go a random direction.
	# Go to a place within a random distance but beyond MIN_MOVE_DISTANCE.
	if randi_range(0, 1) == 0:
		direction = -1
		if position.x - MIN_MOVE_DISTANCE < TARGET_X_MIN:
			next_target_x = TARGET_X_MIN
		else:
			next_target_x = randf_range(TARGET_X_MIN, position.x - MIN_MOVE_DISTANCE)
	else:
		direction = 1
		if position.x + MIN_MOVE_DISTANCE > TARGET_X_MAX:
			next_target_x = TARGET_X_MAX
		else:
			next_target_x = randf_range(position.x + MIN_MOVE_DISTANCE, TARGET_X_MAX)
		
	GodotLogger.info("Steamboat", {"next_target_x" : next_target_x, "direction" : direction})


func _process(delta: float) -> void:
	boat_sprite.scale.x = direction
	
	position.x += SPEED * delta * direction
	
	if direction == -1 and position.x <= next_target_x:
		set_next_target_x()
		
	if direction == 1 and position.x >= next_target_x:
		set_next_target_x()
