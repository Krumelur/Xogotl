class_name Boat
extends Node2D

@onready var boat_sprite : Sprite2D = $BoatSprite

const MIN_SPEED : float = 1
const SLOW_DOWN_DISTANCE : float = 10
const BOAT_ACCELERATION : float = 8
const MAX_SPEED : float = 10.0
const TARGET_X_MIN : int = 40
const TARGET_X_MAX : int = 145
const MIN_MOVE_DISTANCE = 20
const STOP_TIMER_DURATION_SECONDS = 5

var next_target_x : float = 0
var direction : int = 0
var current_speed : float = MIN_SPEED
var stop_timer : float = 0

func _ready() -> void:
	set_next_target_x()


func set_next_target_x() -> void:
	# Go a random direction.
	# Go to a place within a random distance but beyond MIN_MOVE_DISTANCE.
	if randi_range(0, 1) == 0:
		direction = -1
		if position.x - MIN_MOVE_DISTANCE <= TARGET_X_MIN:
			next_target_x = TARGET_X_MIN
		else:
			next_target_x = randf_range(TARGET_X_MIN, position.x - MIN_MOVE_DISTANCE)
	else:
		direction = 1
		if position.x + MIN_MOVE_DISTANCE >= TARGET_X_MAX:
			next_target_x = TARGET_X_MAX
		else:
			next_target_x = randf_range(position.x + MIN_MOVE_DISTANCE, TARGET_X_MAX)
		
	GodotLogger.info("Steamboat", {"next_target_x" : next_target_x, "direction" : direction})


func _process(delta: float) -> void:
	boat_sprite.scale.x = direction
	
	# Get absolute diatance between boat and next stopping point.
	var distance_to_target : float = absf(next_target_x - position.x)
	
	if distance_to_target <= 2:
		next_target_x = position.x
		stop_timer += delta
		if stop_timer >= STOP_TIMER_DURATION_SECONDS:
			stop_timer = 0
			set_next_target_x()
	else:
		# Normalize and clamp to a range of 0..1. 
		# If we're within SLOW_DOWN_DISTANCE, values will be lower than 1 but outside they would be greater 1.
		# That's why we also clamp. Outside of slowwer cirlce we're going full steam.
		var distance_normalized : float = clamp(distance_to_target / SLOW_DOWN_DISTANCE, 0.0, 1.0)
		# Given how far we are away, get the speed we'd like to be at.
		# Could also use ease(distance_normalized, 2) instead of just distance_normalized to have a different acc/dec envelope.
		# See cheatsheet what a value of "2" means: https://raw.githubusercontent.com/godotengine/godot-docs/master/img/ease_cheatsheet.png
		var desired_speed : float =  lerp(MIN_SPEED, MAX_SPEED, distance_normalized)
		
		# Change the current speed towards the desired speed without overshooting.
		current_speed = move_toward(current_speed, desired_speed, BOAT_ACCELERATION * delta)

		position.x += current_speed * delta * direction
		
	create_rod(delta)

var curve_points : PackedVector2Array
var drag_amount : float = 0

func create_rod(delta: float) -> void:
	var points_offset := Vector2(-23.0 * direction, -15.0)
	const NUM_POINTS := 20
	const DEPTH := 100.0
	const DRAG_RESPONSE := 0.5
	const BOW := 3.0
	const TRAIL := 6.0

	drag_amount = move_toward(drag_amount, current_speed, DRAG_RESPONSE * delta)
	
	curve_points.clear()
	curve_points.resize(NUM_POINTS)

	for i in range(NUM_POINTS):
		var t := float(i) / float(NUM_POINTS - 1)
		var y := t * DEPTH

		var bell := 4.0 * t * (1.0 - t)                 # 0..1..0
		var x := bell * BOW * drag_amount * -direction  # mid-bow
		x += lerp(0.0, TRAIL * drag_amount, t) * -direction  # endpoint trail

		curve_points[i] = Vector2(x, y) + points_offset

	queue_redraw()
	
	
func _draw() -> void:
	draw_polyline(curve_points, Color.RED)
	
	
		
func _unhandled_input(event: InputEvent) -> void:
	var touch : InputEventScreenTouch = event as InputEventScreenTouch
	if touch:
		pass
		
