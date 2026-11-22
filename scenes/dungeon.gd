extends Node3D
@onready var eyelids: ColorRect = $HUD/Eyelids
var eyelids_tween: Tween
@export var next_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	eyelids.material.set_shader_parameter("open_amount", 0.0)
	eyelids_tween = create_tween()
	eyelids_tween.tween_property(eyelids.material, "shader_parameter/open_amount", 1.0, 3)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func gameFinished() -> void:
	print("You win!")
	if eyelids_tween:
		eyelids_tween.kill()  # stop the opening tween if it's still running

	eyelids_tween = create_tween()
	eyelids_tween.tween_property(eyelids.material, "shader_parameter/open_amount", 0.0, 3)
	eyelids_tween.tween_callback(func(): get_tree().change_scene_to_packed(next_scene))


func _on_encounter_manager_dungeon_beaten() -> void:
	gameFinished()
