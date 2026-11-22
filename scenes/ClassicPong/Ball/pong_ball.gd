extends Area2D

@onready var bounce: AudioStreamPlayer2D = $Bounce
@export var moving := false
var direction := Vector2(1.0, 1.0)
var ball_speed := 300
@onready var timer: Timer = $Timer
signal playerScored
signal enemyScored
signal playerHurt
var superMode := false
@onready var super_bounce: AudioStreamPlayer2D = $SuperBounce
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_reset()

## Directions: up-right, down-right, down-left, up-left

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if moving:
		position += direction * ball_speed * delta
	
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PongPaddle"):
		direction.x *= -1
		if body.superMode:
			superBounce()
	elif not body.is_in_group("PongOut"):
		direction.y *= -1.0
	_play_bounce_sfx()


func _on_area_entered(area: Area2D) -> void:
	if area.name == "PlayerOut":
		enemyScored.emit()
		if superMode:
			playerHurt.emit()
		else:
			_reset()
	if area.name == "EnemyOut":
		playerScored.emit()
		_reset()
	
	

func _reset() -> void:
	moving = false
	direction = Vector2(1.0, 1.0)
	if not superMode:
		ball_speed = 300
	position = Vector2(0.0, 0.0)
	timer.start()

func _on_timer_timeout() -> void:
	moving = true

func _play_bounce_sfx() -> void:
	bounce.play()

func superBounce() -> void:
	superMode = true
	moving = false
	super_bounce.play()
	ball_speed *= 3
	timer.wait_time /= 2
	timer.start()
