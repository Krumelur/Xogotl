# Pixel font from: https://www.dafont.com/es/press-start.font

class_name GameMain

extends Node2D

# Defines how many points player has to score before a new eel is added
# as an enemy.
@export var increase_max_eels_score_threshold : int = 1000
@export var max_shrimps : int = 4
@export var max_eels : int = 3


@onready var waves_root : Node2D = $Playfield/WavesRoot
@onready var hud : Hud = $CanvasLayerHud/HudRoot
@onready var xogotl : Xogotl = $Playfield/Xogotl
@onready var bubbles_root : Node2D = $Playfield/BubblesRoot
@onready var marker_bubbly_min_y : Marker2D = $Playfield/BubblesMinY
@onready var playfield : Node2D = $Playfield
@onready var boat : Boat = $Playfield/Boat

var is_game_over : bool = false
var next_eel_score : int = 0
	
var score : int = 0:
	set(value):
		GodotLogger.info("Score", value)
		# Check if a new eel is added.
		if score > 0:
			var diff : int = value - score
			next_eel_score += diff
			if next_eel_score >= increase_max_eels_score_threshold:
				next_eel_score -= increase_max_eels_score_threshold
				max_eels += 1
				GodotLogger.info("New max eels", max_eels)
		else:
			next_eel_score = 0
			
		# Update regular score.
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
	is_game_over = false
	hud.hide_game_over()
	
	score = 0
	
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

func game_over(reason : String) -> void:
	hud.show_game_over(reason)
	xogotl.visible = false
	get_tree().paused = true
	is_game_over = true
	
func _process(delta: float) -> void:
	if is_game_over:
		return
	
	var num_shrimps : int = get_tree().get_node_count_in_group("GROUP_SHRIMP")
	var num_eels : int = get_tree().get_node_count_in_group("GROUP_EEL")
	if num_shrimps < max_shrimps:
		playfield.add_child(packed_shrimp.instantiate())
	if num_eels < max_eels:
		playfield.add_child(packed_eel.instantiate())
	
	hud.update_energy(xogotl.energy)
	hud.update_limbs(xogotl.num_limbs, xogotl.get_limb_grow_progress())
	
	# Check if game is over.
	if xogotl.num_limbs <= 0:
		is_game_over = true
		game_over("You lost all your limbs!")
	if xogotl.energy <= 0:
		is_game_over = true
		game_over("Out of energy!")
	
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
	# Eating pond inhabitants increases score and
	# gives the Xogotl back some energy.
	var type : PondInhabitant.INHABITANT_TYPE = inhabitant.get_inhabitant_type()
	match type:
		PondInhabitant.INHABITANT_TYPE.FISH_BONE:
			inhabitant.remove_from_pond()
			score += 50
			xogotl.energy += 0.05
		PondInhabitant.INHABITANT_TYPE.SHRIMP:
			inhabitant.remove_from_pond()
			score += 100
			xogotl.energy += 0.10
		PondInhabitant.INHABITANT_TYPE.WORM:
			inhabitant.remove_from_pond()
			score += 150
			xogotl.energy += 0.15


func _on_boat_request_bait(hook: Node2D) -> void:
	var bait : Node2D  = packed_worm.instantiate()
	hook.add_child(bait)


func _on_xogotl_has_touched_inhabitant(inhabitant: PondInhabitant) -> void:
	var group = inhabitant.get_groups()[0]
	if group == "GROUP_EEL":
		xogotl.hurt(inhabitant)
