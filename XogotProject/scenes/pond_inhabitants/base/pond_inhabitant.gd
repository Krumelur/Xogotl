class_name PondInhabitant
extends Node2D

enum INHABITANT_TYPE {
	UNKNOWN,
	FISH_BONE,
	SHRIMP,
	WORM,
	EEL
}

# Override this in subclass to return correct type.
func get_inhabitant_type() -> INHABITANT_TYPE:
	return INHABITANT_TYPE.UNKNOWN

# Removes the pond inhabitant from the scene.
func remove_from_pond() -> void:
	get_parent().remove_child(self)
	queue_free()
