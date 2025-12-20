class_name Cloud
extends Node2D

@export var speed : float = 2
@onready var cloud_sprite : Sprite2D  = $Cloud

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	position.x += speed * delta
	if position.x > get_viewport_rect().size.x:
		position.x = -cloud_sprite.texture.get_width()
