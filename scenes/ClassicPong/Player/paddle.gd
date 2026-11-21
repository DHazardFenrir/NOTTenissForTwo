extends CharacterBody2D

@export var SPEED = 600.0
@export var isPlayer = true
@export var playerPaddle: CharacterBody2D
@export var ball: Area2D
@onready var color_rect: ColorRect = $ColorRect
@onready var super_mode_sound: AudioStreamPlayer2D = $SuperModeSound

## To trigger the enemy's super animation
@export var superMode := false

func _physics_process(delta: float) -> void:
	if superMode:
		color_rect.material.set_shader_parameter("power", 1.0)
		
	if isPlayer:
		_player_movement(delta)
	else:
		_enemy_movement(delta)
		
	move_and_slide()

func _player_movement(delta: float) -> void:
	var direction := Input.get_axis("up", "down")
	if direction:
		velocity.y = direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		

func _enemy_movement(delta: float) -> void:
	if ball:
		if not superMode:
			var ball_delta = position.y - ball.position.y
			var direction := 0.0
			if ball.position.x > 0 and ball.direction.x > 0.0:
				if ball.position.y < position.y:
					direction = -1.0
				elif ball.position.y > position.y:
					direction = 1.0
				if direction:
					velocity.y = direction * SPEED * 0.5
				else:
					velocity.y = move_toward(velocity.y, 0, SPEED)
			else:
				velocity.y = 0.0
		else:
			position.y = ball.position.y

func enable_super_mode() -> void:
	super_mode_sound.play()
	superMode = true
	
