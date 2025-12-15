class_name Xogotl
extends CharacterBody2D

var local_target_pos: Vector2
var num_limbs := 4

var vel := Vector2.ZERO

const MAX_SPEED := 130.0          # absolute cap
const KICK_SPEED := 200.0         # how strong the initial push is
const DRAG_PER_SEC := 2.0         # higher = stops sooner (water resistance)
const STEER_ACCEL := 100.0        # how much it tries to face the target while gliding
const STOP_RADIUS := 2.0

func _ready() -> void:
	local_target_pos = position

func _physics_process(delta: float) -> void:
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
	keep_within_boundaries()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var global_mouse_pos := get_global_mouse_position()
		local_target_pos = get_parent().to_local(global_mouse_pos)

		var dir := (local_target_pos - position).normalized()
		var limb_factor := 1.0 / float(5 - num_limbs)

		# One strong kick, adds onto current movement (feels like momentum)
		vel += dir * (KICK_SPEED * limb_factor)

func keep_within_boundaries() -> void:
	position.x = clamp(position.x, 8.0, 152.0)
	position.y = clamp(position.y, 120.0, 192.0)