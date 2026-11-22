extends CharacterBody3D

@export var speed := 6.0
@export var turn_speed := 150.0   # grados por segundo
@export var gravity := 20.0
@export var swinging := false
@export var swingPower := 1.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

enum HitStyle { PONG, REFLECT }
@export var hit_style: HitStyle = HitStyle.REFLECT
@export var paddle_half_width := 1.0    # PONG: distance from center to edge of your hitbox
@export var max_bounce_angle := 60.0    # PONG: angle (degrees) when hit at the very edge

var blocking:= false
var next_is_double:= false

func _physics_process(delta):
	# Girar con izquierda/derecha
	#var turn := Input.get_axis("right", "left")
	#rotate_y(deg_to_rad(turn * turn_speed * delta))

	# "Adelante" = hacia donde mira la cámara (sin inclinación)
	#var cam := get_viewport().get_camera_3d()
	#var fwd := -cam.global_basis.z
	#fwd.y = 0
	#fwd = fwd.normalized()

	var input_dir : Vector2 = Input.get_vector("left", "right", "up", "down")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("attack"):
		if not animation_player.is_playing() and not blocking:
			if next_is_double:
				_double_swing()
			else:
				_swing()
			next_is_double = not next_is_double

	if Input.is_action_just_pressed("block"):
		_block()
	if Input.is_action_just_released("block"):
		_unblock()
	
	move_and_slide()

func _swing() -> void:
	animation_player.play("Swing")
	

func _double_swing()-> void:
	animation_player.play("Swing2")
	

func _block()-> void:
	animation_player.play("Block")

func _unblock()-> void:
	animation_player.play("RESET")

func _on_hitbox_body_entered(body: Node3D) -> void:
	print(body.get_groups())
	if not body.is_in_group("Balls"):
		return

	# Player's forward and right, flattened so they're level with the floor
	var forward := -global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := global_basis.x
	right.y = 0.0
	right = right.normalized()

	var dir: Vector3

	match hit_style:
		HitStyle.REFLECT:
			# Mirror the ball's movement, breakout style
			var incoming: Vector3 = body.linear_velocity
			incoming.y = 0.0
			dir = incoming.bounce(forward)
			# Fallback if the ball was barely moving or already heading away
			if dir.length() < 0.01 or dir.dot(forward) <= 0.0:
				dir = forward

		HitStyle.PONG:
			# -1 = hit on the left edge, 0 = center, 1 = right edge
			var offset := (body.global_position - global_position).dot(right)
			var t: float = clamp(offset / paddle_half_width, -1.0, 1.0)
			dir = forward.rotated(Vector3.UP, -t * deg_to_rad(max_bounce_angle))

	dir = dir.normalized()
	body.linear_velocity = Vector3.ZERO  # stop it so the hit feels consistent
	body.apply_central_impulse(dir * swingPower)
	body.reflected = true
