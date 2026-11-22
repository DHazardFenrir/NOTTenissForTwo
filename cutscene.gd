extends Node2D

@export var next_scene: PackedScene
@onready var scream: AudioStreamPlayer2D = $scream
@onready var texture_rect: TextureRect = $TextureRect

@onready var eyelids: ColorRect = $CanvasLayer/Eyelids
@onready var cutscene_timer: Timer = $CutsceneTimer
@onready var defeated: Label = $defeated
@onready var getreal: Label = $getreal
@onready var rtxon: Label = $rtxon
@onready var boom: AudioStreamPlayer2D = $boom


func _ready() -> void:
	eyelids.material.set_shader_parameter("open_amount", 0.0)

	var tween := create_tween()
	tween.tween_property(eyelids.material, "shader_parameter/open_amount", 1.0, 3)  
	tween.tween_interval(cutscene_timer.wait_time)                                    
	tween.tween_property(eyelids.material, "shader_parameter/open_amount", 0.0, 2)  
	tween.tween_callback(func(): get_tree().change_scene_to_packed(next_scene))     

	for l in [defeated, getreal, rtxon]:
			l.modulate.a = 0.0

	var label_tween := create_tween()
	label_tween.tween_interval(3.0)
	label_tween.tween_property(defeated, "modulate:a", 1.0, 0.3)
	label_tween.tween_interval(0.5)
	label_tween.tween_property(getreal, "modulate:a", 1.0, 0.3)
	label_tween.tween_interval(0.5)
	label_tween.tween_callback(_on_third_label)            
	label_tween.tween_property(rtxon, "modulate:a", 1.0, 0.3)                       

func _on_third_label() -> void:
	boom.play()
	texture_rect.pivot_offset = texture_rect.size / 2                    # grow from the center
	create_tween().tween_property(texture_rect, "scale", Vector2(5.0,5.0), 2)


func _on_screamtimer_timeout() -> void:
	scream.play()
