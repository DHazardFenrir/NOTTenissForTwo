extends Node2D
@onready var player_score: Node2D = $PlayerScore
@onready var enemy_score: Node2D = $EnemyScore
@onready var enemy_paddle: CharacterBody2D = $EnemyPaddle
@onready var camera_2d: Camera2D = $Camera2D
@onready var eyelids: ColorRect = $Eyelids
@onready var hurt_sound: AudioStreamPlayer2D = $HurtSound
@onready var bloodsplatter: Node2D = $PlayerPaddle/Bloodsplatter
@onready var player_ded: Sprite2D = $PlayerPaddle/playerDed

var eyelids_tween: Tween

var playerScore := 0
var enemyScore := 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pong_ball_player_scored() -> void:
	playerScore += 1
	player_score.setScore(playerScore)


func _on_pong_ball_enemy_scored() -> void:
	enemyScore += 1
	enemy_score.setScore(enemyScore)

func _on_normal_game_timer_timeout() -> void:
	enemy_paddle.enable_super_mode()
	camera_2d.apply_shake(10.0)
	# This is where the weird stuff starts happening
	

# This is when a powered up ball hits the player.
# This should transition to 3d.
func _on_pong_ball_player_hurt() -> void:
	hurt_sound.play()
	bloodsplatter.splatter()
	player_ded.visible = true
	camera_2d.apply_shake(1.0)
	eyelids_tween = create_tween()
	eyelids_tween.tween_property(eyelids.material, "shader_parameter/open_amount", 0.0, 3)
	eyelids_tween.tween_callback(_go_to_3d)

func _go_to_3d() -> void:
	get_tree().change_scene_to_file("res://scenes/dungeon.tscn")
