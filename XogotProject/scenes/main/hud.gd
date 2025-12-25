class_name Hud
extends Node2D

func update_energy(energy : float) -> void:
	var rect_max = $EnergyMax
	var rect = $EnergyMax/EnergyCurrent
	var label = $EnergyMax/Text
	
	rect.size.x = energy * rect_max.size.x
	label.text = "Energy\n%d%%" % int(round(energy * 100))


func update_score(score : int) -> void:
	$Score.text = "Score\n%04d" % score


func update_limbs(num_limbs : int, grow_progress : float) -> void:
	var rect_max = $LimbsProgressMax
	var rect = $LimbsProgressMax/LimbsProgressCurrent
	var label = $LimbsProgressMax/Text
	
	rect.size.x = grow_progress * rect_max.size.x
	label.text = "Limbs\n%d" % num_limbs
