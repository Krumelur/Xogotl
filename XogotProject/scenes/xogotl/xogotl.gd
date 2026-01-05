class_name Xogotl
extends CharacterBody2D

enum STATE {
	FLOAT,
	MOVE,
	HURT,
}

signal has_eaten_inhabitant(inhabitant : PondInhabitant)
signal has_touched_inhabitant(inhabitant : PondInhabitant)

@onready var sprite : AnimatedSprite2D = $XogotlSprite
@onready var ouch : Node2D = $XogotlSprite/Ouch
@onready var impulse_bubbles_emitter : CPUParticles2D = $XogotlSprite/ImpulseBubblesEmitter

@onready var fx_swim : AudioStreamPlayer = $FX/Swim
@onready var fx_limb : AudioStreamPlayer = $FX/Limb


var local_target_pos: Vector2
var num_limbs : int = 4
var current_state : STATE = STATE.FLOAT
var float_time : float
var energy : float:
	set(value):
		energy = value
		energy  = clamp(energy, 0.0, 1.0)

var bubbles : Array[Bubble] = []

var float_tween : Tween

# Configures floating (idling) behavior.
const FLOAT_AMPLITUDE := 3 
const FLOAT_SPEED := 1


# Configures movement.
const MAX_SPEED := 100.0          # speed cap
const KICK_SPEED := 130.0         # initial push
const DRAG_PER_SEC := 5.0         # higher = stops sooner (water resistance)
const STEER_ACCEL := 20.0        # how much it tries to face the target while gliding
const STOP_RADIUS := 2.0

const LIMB_GROW_DURATION : float = 5
var limb_grow_progress : float = 0

# Losing energy over time (higher value = more loss).
const ENERGY_LOSS_DEFAULT : float = 0.015
# Losing energy when touching enemy (absolute).
const ENERGY_LOSS_ENEMY : float = 0.05
# Losing enemy when moving (absolute).
const ENERGY_LOSS_IMPULSE : float = 0.02


func _ready() -> void:
	impulse_bubbles_emitter.emitting = false
	energy = 1.0
	current_state = STATE.FLOAT
	local_target_pos = position
	
	# Get bubbles.
	bubbles.assign(get_tree().get_nodes_in_group("group_bubbles"))
	
const KNOCKBACK_STRENGTH : float = 300
const KNOCKBACK_DECAY : float = 1000
var knockback_direction : Vector2 = Vector2.ZERO
var knockback_velocity : Vector2 = Vector2.ZERO


func _physics_process(delta: float) -> void:
	if current_state == STATE.FLOAT:
		if not float_tween:
			float_tween = create_tween().set_trans(Tween.TRANS_SINE)
			float_tween.set_loops(0)
			float_tween.tween_property(self, "position:y", FLOAT_AMPLITUDE, FLOAT_SPEED).as_relative()
			float_tween.tween_property(self, "position:y", -FLOAT_AMPLITUDE, FLOAT_SPEED).as_relative()
			float_tween.play()
	elif current_state == STATE.HURT:
		# Apply knockback
		velocity = knockback_velocity
		move_and_slide()
		# Smoothly reduce knockback over time
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, KNOCKBACK_DECAY * delta)
		if knockback_velocity.length() <= 5:
			knockback_velocity = Vector2.ZERO
			velocity = Vector2.ZERO
			current_state = STATE.FLOAT
	else:
		# Moving
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
		
		if velocity.length() <= 4:
			current_state = STATE.FLOAT
			
		if move_and_slide():
			GodotLogger.debug("Collided")
			

func get_limb_grow_progress() -> float:
	if num_limbs < 4:
		return limb_grow_progress / LIMB_GROW_DURATION
	else:
		return 0

func _process(delta: float) -> void:
	energy -= delta * ENERGY_LOSS_DEFAULT
	
	ouch.visible = current_state == STATE.HURT
	
	limb_grow_progress += delta
	if get_limb_grow_progress() >= 1.0:
		GodotLogger.debug("Grow limb progress", limb_grow_progress)
		num_limbs += 1
		limb_grow_progress = 0
		fx_limb.play()

		
	if velocity.x < 0:
		sprite.scale.x = -1.0
		
	if velocity.x > 0:
		sprite.scale.x = 1.0
	
var impulse_bubbles_timer : SceneTreeTimer
func on_impulse_bubbles_timer_timeout() -> void:
	impulse_bubbles_emitter.emitting = false
	sprite.animation = "default"

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		if current_state == STATE.HURT:
			return
			
		fx_swim.play()
		
		# Emit some impulse bubbles.
		impulse_bubbles_timer = get_tree().create_timer(0.5, false)
		impulse_bubbles_emitter.emitting = true
		sprite.animation = "swim"
		impulse_bubbles_timer.timeout.connect(on_impulse_bubbles_timer_timeout)
		
		local_target_pos = event.position
		#local_target_pos.x = clamp(local_target_pos.x, 8.0, 152.0)
		#local_target_pos.y = clamp(local_target_pos.y, 120.0, 192.0)

		var dir := (local_target_pos - position).normalized()
		var limb_factor := 1.0 / float(5 - num_limbs)

		# One strong kick, adds onto current movement (feels like momentum)
		velocity += dir * (KICK_SPEED * limb_factor)
		energy -= ENERGY_LOSS_IMPULSE
		current_state = STATE.MOVE


func _mouth_area_entered(area: Area2D) -> void:
	# Called if AreaMouth collides with another area.
	# Check if we're eating a pond inhabitant and react.
	var inhabitant_collider : PondInhabitantCollider = area as PondInhabitantCollider
	if inhabitant_collider:
		var inhabitant : PondInhabitant = inhabitant_collider.get_inhabitant()
		if inhabitant:
			has_eaten_inhabitant.emit(inhabitant)


func _body_area_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	# Check if we're hitting an evil pond inhabitant.
	var inhabitant_collider : PondInhabitantCollider = area as PondInhabitantCollider
	if inhabitant_collider:
		var inhabitant : PondInhabitant = inhabitant_collider.get_inhabitant()
		if inhabitant:
			has_touched_inhabitant.emit(inhabitant)

func hurt(inhabitant : PondInhabitant) -> void:
	num_limbs -= 1
	limb_grow_progress = 0.0
	GodotLogger.info("Limbs left", num_limbs)
	if current_state == STATE.HURT:
		return
	var knockback_direction : Vector2 = (global_position - inhabitant.global_position).normalized()
	knockback_velocity = knockback_direction * KNOCKBACK_STRENGTH
	current_state = STATE.HURT
	
	energy -= ENERGY_LOSS_ENEMY
