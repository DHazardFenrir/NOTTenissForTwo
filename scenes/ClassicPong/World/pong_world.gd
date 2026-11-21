extends Node2D
@onready var player_score: Node2D = $PlayerScore
@onready var enemy_score: Node2D = $EnemyScore

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
