extends Node3D

signal dungeonBeaten

@export var player: CharacterBody3D
@export var encounters: Array[Encounter]
var encountersCleared:= 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for encounter in encounters:
		encounter.encounterFinished.connect(_on_encounter_finished)
	
	pass # Replace with function body.

func _on_encounter_finished() -> void:
	
	encountersCleared += 1
	print("Encounter finished. ", encountersCleared, " of ", encounters.size())
	if encountersCleared >= encounters.size():
		dungeonBeaten.emit()
	player.unlock()
