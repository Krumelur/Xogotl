class_name Hud
extends Node2D

func update_energy(energy : int) -> void:
	$Energy.text = "Energy\n%03d%%" % energy


func update_score(score : int) -> void:
	$Score.text = "Score\n%04d" % score


func update_limbs(num_limbs : int, grow_progress : float) -> void:
	var rect = $LimbsProgressMax/LimbsProgressCurrent
	var limbs = $LimbsProgressMax/Limbs
	
	rect.size.x = grow_progress * 50
	limbs.text = "Limbs\n%d" % num_limbs
