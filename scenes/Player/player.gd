extends CharacterBody3D

signal reached_stop(index)

@export var speed = 4.0
@export var turn_speed = 6.0
@export var dodge_speed = 5.0
@export var dodge_side = 3.0
@export var dodge_back = 1.5
@export var swing_power = 15.0
@export var block_power = 8.0
@export var max_health = 5
@export var stops = [16.13, 96.72, 193.0, 254.13, 366.48, 473.18]

@onready var follow = get_parent()
@onready var anim = $AnimationPlayer

var stopped = false
var next_stop = 0
var yaw = 0.0
var health = 5
var double_swing = false


func _ready():
	add_to_group("player")
	health = max_health
	yaw = follow.global_rotation.y

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
	if not stopped:
		follow.progress += speed * delta

		if next_stop < stops.size() and follow.progress >= stops[next_stop]:
			follow.progress = stops[next_stop]
			stopped = true
			reached_stop.emit(next_stop)
			print("Stop ", next_stop)
			next_stop += 1

	if stopped:
		if Input.is_action_pressed("left"):
			position.x -= dodge_speed * delta
		if Input.is_action_pressed("right"):
			position.x += dodge_speed * delta
		if Input.is_action_pressed("down"):
			position.z += dodge_speed * delta
		if Input.is_action_pressed("up"):
			position.z -= dodge_speed * delta

		position.x = clamp(position.x, -dodge_side, dodge_side)
		position.z = clamp(position.z, 0, dodge_back)
	else:
		position.x = move_toward(position.x, 0, dodge_speed * delta)
		position.z = move_toward(position.z, 0, dodge_speed * delta)

	yaw = lerp_angle(yaw, follow.global_rotation.y, turn_speed * delta)
	rotation.y = yaw - follow.global_rotation.y

	if Input.is_action_just_pressed("attack") and not anim.is_playing() and not blocking:
		if double_swing:
			anim.play("Swing2")
		else:
			anim.play("Swing")
		double_swing = not double_swing

	if Input.is_action_just_pressed("block"):
		blocking = true
		anim.play("Block")

	if Input.is_action_just_released("block"):
		blocking = false
		anim.play_backwards("Block")

	if stopped and Input.is_action_just_pressed("ui_accept"):
		unlock()


func unlock():
	stopped = false

func take_damage(amount):
	if blocking:
		return


func _on_hitbox_body_entered(body: Node3D):
	if not body.is_in_group("ball"):
		return

	var power = 0.0
	if blocking:
		power = block_power
	elif anim.current_animation == "Swing" or anim.current_animation == "Swing2":
		power = swing_power
	else:
		return

	var dir = -global_basis.z
	dir.y = 0.2
	body.linear_velocity = Vector3.ZERO
	body.apply_central_impulse(dir.normalized() * power)
	body.reflected = true
	if not body.is_in_group("Balls"):
		return

	# Player's forward and right, flattened so they're level with the floor
	var forward := -global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := global_basis.x
	right.y = 0.0
	right = right.normalized()

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
	body.apply_central_impulse(dir * swing_power)
	body.reflected = true
	
	## TODO: Not sure where amount comes from
	## HARDCODEADO
	var amount = 1
	## FIX SOON
	health -= amount
	print("Vida: ", health)

	if health <= 0:
		get_tree().reload_current_scene()
	if  blocking:
		return

	health -= amount
	print("Health: ", health)

	if health <= 0:
		get_tree().reload_current_scene()
		return

	
	await get_tree().create_timer(0.8).timeout
	
