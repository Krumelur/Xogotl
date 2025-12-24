@tool
class_name PondInhabitantCollider
extends Area2D

# Gets the pond inhabitant this collider is attached to.
func get_inhabitant() -> PondInhabitant:
	var parent : Node = get_parent()
	if parent is PondInhabitant:
		return parent as PondInhabitant
	else:
		GodotLogger.error("Cannot get PondInhabitant", self)
		return null
