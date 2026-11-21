extends CharacterBody3D

@export var speed := 6.0
@export var turn_speed := 150.0   # grados por segundo
@export var gravity := 20.0

func _physics_process(delta):
	# Girar con izquierda/derecha
	var turn := Input.get_axis("right", "left")
	rotate_y(deg_to_rad(turn * turn_speed * delta))

	# "Adelante" = hacia donde mira la cámara (sin inclinación)
	var cam := get_viewport().get_camera_3d()
	var fwd := -cam.global_basis.z
	fwd.y = 0
	fwd = fwd.normalized()

	var forward := Input.get_axis("down", "up")
	var dir := fwd * forward

	velocity.x = dir.x * speed
	velocity.z = dir.z * speed

	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()
