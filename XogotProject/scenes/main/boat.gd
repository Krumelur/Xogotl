class_name Boat
extends Node2D

enum STATUS {
	MOVING,
	STOPPED,
	LOWERING_HOOK,
	FISHING,
	RAISING_HOOK
}

signal request_bait(hook : Node2D)

@onready var boat_sprite : Sprite2D = $BoatSprite
@onready var hook : Node2D = $Hook
@onready var marker_line_start_left : Marker2D = $MarkerLineStartLeft
@onready var marker_line_start_right : Marker2D = $MarkerLineStartRight

const MIN_SPEED : float = 1
const SLOW_DOWN_DISTANCE : float = 10
const BOAT_ACCELERATION : float = 8
const MAX_SPEED : float = 10.0
const TARGET_X_MIN : int = 40
const TARGET_X_MAX : int = 145
const MIN_MOVE_DISTANCE = 20
const STOP_TIMER_DURATION_SECONDS = 5
const HOOK_SPEED : float = 10
const MIN_HOOK_DEPTH : int = 40
const MAX_HOOK_DEPTH : int = 105
const MIN_FISHING_DURATION : float = 2
const MAX_FISHING_DURATION : float = 5

var bait : Node2D = null

var current_status : STATUS = STATUS.MOVING
var current_hook_depth : float = 0

var next_target_x : float = 0
var direction : int = 1
var current_speed : float = MIN_SPEED
var stop_timer : float = 0

var current_hook_marker : Marker2D
	

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

var hook_target_depth : int
var current_fishing_duration : float

func _process(delta: float) -> void:
	# Provided by main game when receiveing signal to provide a bait.
	if hook.get_child_count() > 0:
		bait = hook.get_child(0)
		bait.position = Vector2(0, 0)
	
	boat_sprite.scale.x = direction
	current_hook_marker = marker_line_start_left if direction > 0 else marker_line_start_right
	
	# Boat is fishing.
	if current_status == STATUS.FISHING:
		current_fishing_duration -= delta
		if current_fishing_duration < 0:
			current_status = STATUS.RAISING_HOOK
			GodotLogger.info("Boat done fishing. New status RAISING_HOOK.")
	# Raise hook after fishing for a while.
	elif current_status == STATUS.RAISING_HOOK:
		if raise_hook(delta):
			GodotLogger.info("Hook is up. Boat now MOVING.")
			current_status = STATUS.MOVING
			set_next_target_x()
	# Boat has stopped and will lower hook.
	elif current_status == STATUS.STOPPED:
		hook_target_depth = randi_range(MIN_HOOK_DEPTH, MAX_HOOK_DEPTH)
		GodotLogger.info("Boat has STOPPED. Lowering hook. Target hook depth:", hook_target_depth)
		request_bait.emit(hook)
		current_status = STATUS.LOWERING_HOOK
	# Boat is stopped and hook is being lowered.
	elif current_status == STATUS.LOWERING_HOOK:
		if lower_hook(delta):
			current_status = STATUS.FISHING
			current_fishing_duration = randf_range(MIN_FISHING_DURATION, MAX_FISHING_DURATION)
			GodotLogger.info("Boat hook lowered. New status is FISHING. Fishing duration:", current_fishing_duration)
	# Boat is moving towards a new position.
	elif current_status == STATUS.MOVING:
		if bait:
			hook.remove_child(bait)
			bait = null
			
		hook.position = current_hook_marker.position
		# Get absolute diatance between boat and next stopping point.
		var distance_to_target : float = absf(next_target_x - position.x)
		
		if distance_to_target <= 2:
			next_target_x = position.x
			stop_timer += delta
			if stop_timer >= STOP_TIMER_DURATION_SECONDS:
				stop_timer = 0
				# Move into STOPPED status so that boat begins fishing.
				current_status = STATUS.STOPPED
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

		
# Lowers hook and returns true if target hook depth has been reached.
func lower_hook(delta : float) -> bool:
	var has_reached_depth : bool = false
	current_hook_depth += delta * HOOK_SPEED
	
	if current_hook_depth > hook_target_depth:
		current_hook_depth = hook_target_depth
		has_reached_depth = true
	
	hook.position.x = current_hook_marker.position.x
	hook.position.y = current_hook_marker.position.y + current_hook_depth
	queue_redraw()
	return has_reached_depth


# Raises hook and returns true if hook has resurfaced.
func raise_hook(delta : float) -> bool:
	current_hook_depth -= delta * HOOK_SPEED
	
	if current_hook_depth < 0:
		current_hook_depth = 0
		hook.position = current_hook_marker.position
		return true
	
	hook.position.x = current_hook_marker.position.x
	hook.position.y = current_hook_marker.position.y + current_hook_depth
	queue_redraw()
	return false


	
func _draw() -> void:
	if current_status in [STATUS.LOWERING_HOOK, STATUS.FISHING, STATUS.RAISING_HOOK]:
		draw_line(current_hook_marker.position, hook.position, Color.html("b8b8b8"))
