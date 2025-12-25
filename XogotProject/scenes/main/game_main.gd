# Pixel font from: https://www.dafont.com/es/press-start.font

class_name GameMain

extends Node2D

@export var max_shrimps : int = 4
@export var max_eels : int = 3

@onready var waves_root : Node2D = $Playfield/WavesRoot
@onready var hud : Hud = $CanvasLayerHud/HudRoot
@onready var xogotl : Xogotl = $Playfield/Xogotl
@onready var bubbles_root : Node2D = $Playfield/BubblesRoot
@onready var marker_bubbly_min_y : Marker2D = $Playfield/BubblesMinY
@onready var playfield : Node2D = $Playfield
@onready var boat : Boat = $Playfield/Boat

	
var score : int = 0:
	set(value):
		GodotLogger.info("Score", value)
		score = value
		hud.update_score(score)

const WAVES_AMPLITUDE : int = 1
const WAVES_SPEED : float = 3

var bubble_scene : PackedScene
const MAX_BUBBLES : int = 3
const BUBBLES_RANDOM_THRESHOLD : float = 0.995

const PROBALITY_TIMERANGE_SECONDS : float = 5.0
var probability_timer : float = PROBALITY_TIMERANGE_SECONDS

# Get a random value between 0..1 every PROBALITY_TIMERANGE_SECONDS.
# If that value is grater than FISHBONE_PROBABILITY, drop a fishbone into the water.
const FISHBONE_PROBABILITY : float = 0.6

var packed_fishbone : PackedScene
var packed_shrimp : PackedScene
var packed_eel : PackedScene
var packed_worm : PackedScene

func _ready() -> void:
	# A tween to make waves animate up and down.
	var waves_tween = create_tween()
	waves_tween.set_loops(0)
	waves_tween.tween_property(waves_root, "position:y", -WAVES_AMPLITUDE, WAVES_SPEED).as_relative()
	waves_tween.tween_property(waves_root, "position:y", +WAVES_AMPLITUDE, WAVES_SPEED).as_relative()
	waves_tween.play()

	# Preload dynamic scenes.
	bubble_scene = preload("res://scenes/xogotl/bubble.tscn")
	packed_fishbone = preload("res://scenes/pond_inhabitants/fish_bone.tscn")
	
	packed_shrimp = preload("res://scenes/pond_inhabitants/shrimp.tscn")
	packed_eel = preload("res://scenes/pond_inhabitants/eel.tscn")
	packed_worm = preload("res://scenes/pond_inhabitants/worm.tscn")
	
	hud.update_limbs(xogotl.num_limbs, xogotl.get_limb_grow_progress())


func _process(delta: float) -> void:
	var num_shrimps : int = get_tree().get_node_count_in_group("GROUP_SHRIMP")
	var num_eels : int = get_tree().get_node_count_in_group("GROUP_EEL")
	if num_shrimps < max_shrimps:
		playfield.add_child(packed_shrimp.instantiate())
	if num_eels < max_eels:
		playfield.add_child(packed_eel.instantiate())
	
	hud.update_energy(xogotl.energy)
	hud.update_limbs(xogotl.num_limbs, xogotl.get_limb_grow_progress())
	
	# If Xogotl is floating let him exhale bubbles.
	if xogotl.current_state == Xogotl.STATE.FLOAT:
		if bubbles_root.get_child_count() < MAX_BUBBLES:
			if randf() > BUBBLES_RANDOM_THRESHOLD:
				var bubble : Bubble = bubble_scene.instantiate()
				bubble.initialize(xogotl.global_position + Vector2(5 + randi_range(-5, +5), -15), marker_bubbly_min_y.global_position.y)
				bubbles_root.add_child(bubble)
				
	
	# Let the boat randomly drop fish bones.
	probability_timer -= delta
	if probability_timer < 0:
		probability_timer += PROBALITY_TIMERANGE_SECONDS
		
		var random_percentage : float = randf()
		GodotLogger.info("Probability timer is up", {"duration" : PROBALITY_TIMERANGE_SECONDS, "random_percentage" : random_percentage})
		if random_percentage >= 1.0 - FISHBONE_PROBABILITY:
			# Only drop a fishbone if the boat is moving.
			if boat.current_status == Boat.STATUS.MOVING:
				drop_fishbone()



func drop_fishbone() -> void:
	var fishbone : FishBone = packed_fishbone.instantiate()
	fishbone.global_position = boat.global_position + Vector2(0, -10)
	playfield.add_child(fishbone)


func _on_xogotl_has_eaten_inhabitant(inhabitant: PondInhabitant) -> void:
	var type : PondInhabitant.INHABITANT_TYPE = inhabitant.get_inhabitant_type()
	match type:
		PondInhabitant.INHABITANT_TYPE.FISH_BONE:
			inhabitant.remove_from_pond()
			score += 5
		PondInhabitant.INHABITANT_TYPE.SHRIMP:
			inhabitant.remove_from_pond()
			score += 10
		PondInhabitant.INHABITANT_TYPE.WORM:
			inhabitant.remove_from_pond()
			score += 15


func _on_boat_request_bait(hook: Node2D) -> void:
	var bait : Node2D  = packed_worm.instantiate()
	hook.add_child(bait)


func _on_xogotl_has_touched_inhabitant(inhabitant: PondInhabitant) -> void:
	var group = inhabitant.get_groups()[0]
	if group == "GROUP_EEL":
		xogotl.hurt(inhabitant)
