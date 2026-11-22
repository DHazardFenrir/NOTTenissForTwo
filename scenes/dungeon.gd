extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func gameFinished() -> void:
	#THIS IS WHERE WE SHOULD SPAWN THE END BIT
	print("You win!")


func _on_encounter_manager_dungeon_beaten() -> void:
	gameFinished()
