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
var blocking = false
var double_swing = false


func _ready():
	add_to_group("player")
	health = max_health
	yaw = follow.global_rotation.y


func _physics_process(delta):
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


func _on_hitbox_body_entered(body):
	print(anim.current_animation)
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


func take_damage(amount = 1):
	if blocking:
		return
	health -= amount
	print("Health: ", health)
	if health <= 0:
		get_tree().reload_current_scene()


func _on_hurtbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("Balls"):
		take_damage(body.damage)
		body.ball_death()
