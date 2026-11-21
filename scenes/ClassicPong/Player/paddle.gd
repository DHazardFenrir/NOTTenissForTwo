extends CharacterBody2D


@export var SPEED = 600.0
@export var isPlayer = true
@export var playerPaddle: CharacterBody2D


func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if isPlayer:
		var direction := Input.get_axis("up", "down")
		if direction:
			velocity.y = direction * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)
	else:
		if playerPaddle:
			var direction := 0
			if playerPaddle.position.y < position.y:
				direction = -1.0
			elif playerPaddle.position.y > position.y:
				direction = 1.0
			if direction:
				velocity.y = direction * SPEED
			else:
				velocity.y = move_toward(velocity.y, 0, SPEED)
		
	move_and_slide()
