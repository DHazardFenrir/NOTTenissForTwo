class_name Encounter
extends Node3D

signal encounterFinished

@export var enemy_amount := 1
@export var ball_amount := 1
@export var enemy_texture: Texture2D
@export var enemy_vertical_scale:= 1.0

@onready var enemy_spawn_shape: CollisionShape3D = $EnemyArea/CollisionShape3D
@onready var ball_spawn_shape: CollisionShape3D = $BallSpawner/BallCollisionShape
@onready var ball_parent: Node3D = $BallParent

var enemy_scene := preload("res://scenes/Enemy/enemy.tscn")
var ball_scene := preload("res://scenes/Ball/ball.tscn")

var encounter_started := false
var encounter_finished := false
var enemies_alive := 0


func _on_player_walk_in_area_body_entered(body: Node3D) -> void:
	if encounter_started or not body.is_in_group("Player"):
		return
	encounter_started = true

	spawn_enemies()
	spawn_balls()


func spawn_enemies() -> void:
	enemies_alive = enemy_amount
	for i in enemy_amount:
		var e := enemy_scene.instantiate()
		e.sprite_texture = enemy_texture
		e.deadEnemySignal.connect(_on_enemy_died)
		e.scale.y = enemy_vertical_scale
		add_child(e)  # add first...
		e.global_position = get_random_point_in_area(enemy_spawn_shape)  # ...then place globally


func _on_enemy_died() -> void:
	if encounter_finished:
		return
	enemies_alive -= 1
	if enemies_alive <= 0:
		finish_encounter()


func finish_encounter() -> void:
	encounter_finished = true 
	_clear_balls()
	encounterFinished.emit()


func spawn_balls() -> void:
	if encounter_finished:
		return
	while _active_ball_count() < ball_amount:
		var b := ball_scene.instantiate() as RigidBody3D
		b.ballDeath.connect(_on_ball_destroyed)
		ball_parent.add_child(b)
		b.global_position = get_random_point_in_area(ball_spawn_shape)
		var dir := enemy_spawn_shape.global_position - b.global_position
		dir.y = 0.0
		b.apply_central_impulse(dir.normalized() * 0.5)


func _on_ball_destroyed() -> void:
	if not encounter_finished:
		spawn_balls.call_deferred()


func _active_ball_count() -> int:
	var count := 0
	for child in ball_parent.get_children():
		if not child.is_queued_for_deletion():
			count += 1
	return count

func _clear_balls() -> void:
	for child in ball_parent.get_children():
		child.queue_free()

func get_random_point_in_area(col: CollisionShape3D) -> Vector3:
	var local := Vector3.ZERO
	var shape := col.shape

	if shape is BoxShape3D:
		var half: Vector3 = shape.size * 0.5
		local = Vector3(randf_range(-half.x, half.x), 0.0, randf_range(-half.z, half.z))
	else:
		push_warning("Unsupported spawn shape: %s. Should be BoxShape3D" % shape)

	return col.global_transform * local
