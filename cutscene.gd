extends Node2D

@export var next_scene: PackedScene

@onready var eyelids: ColorRect = $CanvasLayer/Eyelids
@onready var cutscene_timer: Timer = $CutsceneTimer


func _ready() -> void:
	eyelids.material.set_shader_parameter("open_amount", 0.0)

	var tween := create_tween()
	tween.tween_property(eyelids.material, "shader_parameter/open_amount", 1.0, 3)  # open
	tween.tween_interval(cutscene_timer.wait_time)                                    # stay open
	tween.tween_property(eyelids.material, "shader_parameter/open_amount", 0.0, 3)  # close
	tween.tween_callback(func(): get_tree().change_scene_to_packed(next_scene))     # next scene
