class_name Xogotl
extends CharacterBody2D

enum STATE {
	FLOAT,
	MOVE
}


var local_target_pos: Vector2
var num_limbs := 4
var vel := Vector2.ZERO
var current_state : STATE = STATE.FLOAT
var float_position : Vector2
var float_time : float

# Configures floating (idling) behavior.
const FLOAT_AMPLITUDE := 4 
const FLOAT_FREQUENCY := 0.3

# Configures movement.
const MAX_SPEED := 130.0          # speed cap
const KICK_SPEED := 200.0         # initial push
const DRAG_PER_SEC := 3.0         # higher = stops sooner (water resistance)
const STEER_ACCEL := 100.0        # how much it tries to face the target while gliding
const STOP_RADIUS := 2.0

func _ready() -> void:
	current_state = STATE.FLOAT
	local_target_pos = position
	float_position = position

func _physics_process(delta: float) -> void:
	if current_state == STATE.FLOAT:
		float_time += delta
		position = Vector2(float_position.x, float_position.y + sin(float_time * TAU * FLOAT_FREQUENCY) * FLOAT_AMPLITUDE)
	else:
		var limb_factor := 1.0 / float(5 - num_limbs) # 4 limbs => 1.0, fewer => slower
		var max_speed := MAX_SPEED * limb_factor
	
		var to_target := local_target_pos - position
		var dist := to_target.length()
	
		# Steering: gently accelerates toward target while still preserving inertia
		if dist > STOP_RADIUS:
			var dir := to_target / dist
			vel += dir * (STEER_ACCEL * limb_factor) * delta
		else:
			# Near target: bleed velocity so it settles instead of orbiting
			vel = vel.move_toward(Vector2.ZERO, (STEER_ACCEL * 2.0) * delta)
			
		# Water drag: exponential-ish decay, stable across FPS
		var drag := exp(-DRAG_PER_SEC * delta)
		vel *= drag
		
		# Cap speed
		if vel.length() > max_speed:
			vel = vel.normalized() * max_speed
	
		position += vel * delta
		
		if vel.length() <= 0.02:
			current_state = STATE.FLOAT
			float_position = position
			float_time = 0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var global_mouse_pos := get_global_mouse_position()
		local_target_pos = get_parent().to_local(global_mouse_pos)
		local_target_pos.x = clamp(local_target_pos.x, 8.0, 152.0)
		local_target_pos.y = clamp(local_target_pos.y, 120.0, 192.0)

		var dir := (local_target_pos - position).normalized()
		var limb_factor := 1.0 / float(5 - num_limbs)

		# One strong kick, adds onto current movement (feels like momentum)
		vel += dir * (KICK_SPEED * limb_factor)
		
		current_state = STATE.MOVE

	