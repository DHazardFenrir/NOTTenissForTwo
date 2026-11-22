extends CharacterBody3D

@export var speed := 6.0
@export var turn_speed := 150.0   # grados por segundo
@export var gravity := 20.0
@export var swinging := false
@export var swingPower := 1.0
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _physics_process(delta):
	# Girar con izquierda/derecha
	#var turn := Input.get_axis("right", "left")
	#rotate_y(deg_to_rad(turn * turn_speed * delta))

	# "Adelante" = hacia donde mira la cámara (sin inclinación)
	var cam := get_viewport().get_camera_3d()
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
		_swing()
	move_and_slide()

func _swing() -> void:
	animation_player.play("Swing")
	

func _on_hitbox_body_entered(body: Node3D) -> void:
	print(body)
	if body.is_in_group("Ball"):
		var dir := -global_basis.z          # player's facing direction
		dir.y = 0.2                         # optional slight lift
		body.linear_velocity = Vector3.ZERO # stop it so the hit feels consistent
		body.apply_central_impulse(dir.normalized() * swingPower)
		body.reflected = true
