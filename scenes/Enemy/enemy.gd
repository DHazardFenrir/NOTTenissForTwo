extends Node3D

enum Difficulty { EASY, MEDIUM, HARD }
enum HitStyle { PONG, REFLECT }

@export var hit_style: HitStyle = HitStyle.PONG
@export var hit_power := 1.0
@export var paddle_half_width := 1.0
@export var max_bounce_angle := 60.0
@export var walkable_area: Area3D
@export var difficulty: Difficulty = Difficulty.MEDIUM
@export var health = 1
@export var sprite_texture: Texture2D
@onready var paladin: Node3D = $Paladin
@onready var deathsound: AudioStreamPlayer3D = $deathsound

@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var hurtbox: Area3D = $Hurtbox

var death_particles := preload("res://scenes/particles/explosion3d.tscn")

signal deadEnemySignal

var _min: Vector3
var _max: Vector3
var _target_ball: Node3D
var _recheck_timer := 0.0

func _ready() -> void:
	if sprite_texture:
		sprite_3d.texture = sprite_texture
		sprite_3d.visible = true
	else:
		paladin.visible = true
	var col := walkable_area.get_node("CollisionShape3D") as CollisionShape3D
	var size := (col.shape as BoxShape3D).size
	# AABB helps with rotation, keeping the pov of the enemy
	# but adjusting the axis it's going to move in (Z or X)
	var world_box: AABB = col.global_transform * AABB(-size / 2.0, size)
	_min = world_box.position
	_max = world_box.end

func _physics_process(delta: float) -> void:
	_choose_ball(delta)
	if not is_instance_valid(_target_ball):
		return

	var target := global_position
	target.x = clamp(_target_ball.global_position.x, _min.x, _max.x)
	target.z = clamp(_target_ball.global_position.z, _min.z, _max.z)

	global_position = global_position.move_toward(target, _get_speed() * delta)

func _get_speed() -> float:
	match difficulty:
		Difficulty.EASY:
			return 1.0
		Difficulty.MEDIUM:
			return 2.5
		_:  # HARD
			return 4.0

func _choose_ball(delta: float) -> void:
	_recheck_timer -= delta

	match difficulty:
		Difficulty.EASY:
			# Grab any ball
			if _recheck_timer <= 0.0 or not is_instance_valid(_target_ball):
				_target_ball = _random_ball()
				_recheck_timer = 2.0
		Difficulty.MEDIUM:
			# Smart, but slow to react
			if _recheck_timer <= 0.0 or not is_instance_valid(_target_ball):
				_target_ball = _nearest_ball()
				_recheck_timer = 0.5
		Difficulty.HARD:
			# Tracks closest ball
			_target_ball = _nearest_ball()

func _random_ball() -> Node3D:
	var balls := get_tree().get_nodes_in_group("Balls")
	if balls.is_empty():
		return null
	return balls.pick_random()

func _nearest_ball() -> Node3D:
	var nearest: Node3D = null
	var best_dist := INF
	for ball in get_tree().get_nodes_in_group("Balls"):
		#distance squared is faster
		var dist: float = global_position.distance_squared_to(ball.global_position)
		if dist < best_dist:
			best_dist = dist
			nearest = ball
	return nearest


func _on_hitbox_body_entered(body: Node3D) -> void:
	print(body.get_groups())
	if not body.is_in_group("Balls"):
		return

	#global basis is the node's rotation
	var forward := -global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	var right := global_basis.x
	right.y = 0.0
	right = right.normalized()

	var dir: Vector3

	match hit_style:
		HitStyle.REFLECT:
			var incoming: Vector3 = body.linear_velocity
			incoming.y = 0.0
			dir = incoming.bounce(forward)
			if dir.length() < 0.01 or dir.dot(forward) <= 0.0:
				dir = forward

		HitStyle.PONG:
			var offset := (body.global_position - global_position).dot(right)
			var t: float = clamp(offset / paddle_half_width, -1.0, 1.0)
			dir = forward.rotated(Vector3.UP, -t * deg_to_rad(max_bounce_angle))

	body.linear_velocity = Vector3.ZERO
	body.apply_central_impulse(dir.normalized() * hit_power)

var is_dead := false

func _on_hurtbox_body_entered(body: Node3D) -> void:
	if not body.is_in_group("Balls") or body.is_queued_for_deletion():
		return
	# consume the ball first, so other enemies ignore it
	body.ball_death()      
	_enemy_take_damage()

func _enemy_take_damage(value = 1) -> void:
	if is_dead:
		return
	health -= value
	if health <= 0:
		_enemy_death()

func _enemy_death() -> void:
	is_dead = true
	hurtbox.set_deferred("monitoring", false)
	deathsound.play()
	var fx := death_particles.instantiate()
	get_parent().add_child(fx)
	fx.global_position = global_position
	
	deadEnemySignal.emit()
	queue_free()
	
