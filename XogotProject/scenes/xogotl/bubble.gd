class_name Bubble
extends Node2D

const BUBBLE_MIN_SPEED := 2.0
const BUBBLE_MAX_SPEED := 4.0
const BUBBLE_MAX_X_OFFSET := 4
const MIN_Y := 20

var speed : float = 0

func initialize() -> void:
	visible = true
	position = Vector2(0, 0)
	position.x += randi_range(-BUBBLE_MAX_X_OFFSET, +BUBBLE_MAX_X_OFFSET)
	speed = randf_range(BUBBLE_MIN_SPEED, BUBBLE_MAX_SPEED)
	
func reset() -> void:
	visible = false
	position = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if visible:
		position.y -= delta * speed
		
	if global_position.y <= MIN_Y:
		visible = false
