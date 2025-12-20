class_name Bubble
extends Node2D

const BUBBLE_MIN_SPEED := 8.0
const BUBBLE_MAX_SPEED := 16.0

var _min_global_y : float = 0
var _speed : float = 0

func initialize(start_global_pos : Vector2, min_global_y : float) -> void:
	_min_global_y = min_global_y
	global_position = start_global_pos
	set_random_speed()
	visible = true

func set_random_speed() -> void:
	_speed = randf_range(BUBBLE_MIN_SPEED, BUBBLE_MAX_SPEED)

func _physics_process(delta: float) -> void:
	if visible:
		position.y -= delta * _speed
		
	# Let bubbles move up to the marker's Y position, then hide.
	if global_position.y < _min_global_y:
		visible = false
		get_parent().remove_child(self)
