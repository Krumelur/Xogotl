class_name Xogotl
extends CharacterBody2D

enum STATE {
	FLOAT,
	MOVE
}

signal has_eaten_inhabitant(inhabitant : PondInhabitant)

var local_target_pos: Vector2
var num_limbs := 4
var current_state : STATE = STATE.FLOAT
var float_position : Vector2
var float_time : float

var float_tween : Tween

# Configures floating (idling) behavior.
const FLOAT_AMPLITUDE := 3 
const FLOAT_SPEED := 1

# Configures movement.
const MAX_SPEED := 130.0          # speed cap
const KICK_SPEED := 160.0         # initial push
const DRAG_PER_SEC := 3.0         # higher = stops sooner (water resistance)
const STEER_ACCEL := 70.0        # how much it tries to face the target while gliding
const STOP_RADIUS := 2.0

func _ready() -> void:
	current_state = STATE.FLOAT
	local_target_pos = position
	float_position = position

func _physics_process(delta: float) -> void:
	if current_state == STATE.FLOAT:
		if not float_tween:
			float_position = position
			float_tween = create_tween().set_trans(Tween.TRANS_SINE)
			float_tween.set_loops(0)
			float_tween.tween_property(self, "position:y", float_position.y - FLOAT_AMPLITUDE, FLOAT_SPEED)
			float_tween.tween_property(self, "position:y", float_position.y + FLOAT_AMPLITUDE, FLOAT_SPEED)
			float_tween.play()
	else:
		if float_tween:
			float_tween.stop()
			float_tween = null
		
		var limb_factor := 1.0 / float(5 - num_limbs) # 4 limbs => 1.0, fewer => slower
		var max_speed := MAX_SPEED * limb_factor
	
		var to_target := local_target_pos - position
		var dist := to_target.length()
	
		# Steering: gently accelerates toward target while still preserving inertia
		if dist > STOP_RADIUS:
			var dir := to_target / dist
			velocity += dir * (STEER_ACCEL * limb_factor) * delta
		else:
			# Near target: bleed velocity so it settles instead of orbiting
			velocity = velocity.move_toward(Vector2.ZERO, (STEER_ACCEL * 2.0) * delta)
			
		# Water drag: exponential-ish decay, stable across FPS
		var drag := exp(-DRAG_PER_SEC * delta)
		velocity *= drag
		
		# Cap speed
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
		
		if velocity.length() <= 0.02:
			current_state = STATE.FLOAT
			
		if move_and_slide():
			GodotLogger.info("Collided")


func _unhandled_input(event: InputEvent) -> void:
	var touch : InputEventScreenTouch = event as InputEventScreenTouch
	if touch:
		local_target_pos = touch.position
		local_target_pos.x = clamp(local_target_pos.x, 8.0, 152.0)
		local_target_pos.y = clamp(local_target_pos.y, 120.0, 192.0)

		var dir := (local_target_pos - position).normalized()
		var limb_factor := 1.0 / float(5 - num_limbs)

		# One strong kick, adds onto current movement (feels like momentum)
		velocity += dir * (KICK_SPEED * limb_factor)
		
		current_state = STATE.MOVE


func _mouth_area_entered(area: Area2D) -> void:
	# Called if AreaMouth collides with another area.
	# Check if we're esting a pond inhabitant and react.
	var inhabitant_collider : PondInhabitantCollider = area as PondInhabitantCollider
	if inhabitant_collider:
		var inhabitant : PondInhabitant = inhabitant_collider.get_inhabitant()
		if inhabitant:
			has_eaten_inhabitant.emit(inhabitant)
			var inhabitant_type : PondInhabitant.INHABITANT_TYPE = inhabitant.get_inhabitant_type()
			GodotLogger.info("Xogotl eating", inhabitant_type)
	
	
	
