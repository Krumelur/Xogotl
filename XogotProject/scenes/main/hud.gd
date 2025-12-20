class_name Hud
extends Node2D

func update_energy(energy : int) -> void:
	$Score.text = "%03d%%" % energy


func update_score(score : int) -> void:
	$Score.text = "%04d" % score
