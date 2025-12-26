extends CanvasLayer

signal on_transition_finished

@onready var color_rect = $ColorRect
@onready var animation_payer = $AnimationPlayer

func _ready() -> void:
	color_rect.visible = false
	animation_payer.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished(anim_name) -> void:
	if anim_name == "fade_out":
		on_transition_finished.emit()
		animation_payer.play("fade_in")
	elif anim_name == "fade_in":
		color_rect.visible = false
		
func transition() -> void:
	color_rect.visible = true
	animation_payer.play("fade_out")
