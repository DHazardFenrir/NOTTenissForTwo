extends Node3D

# The purpose of this script is to handle each encounter
# Each encounter should have at least one enemy DONE
# And each encounter should have at least one ball active at all times. NOT DONE

@export var enemy_amount:= 1
@export var ball_amount:= 1
@export var enemy_area: Area3D
@export var encounter_started:= false
@onready var collision_shape_3d: CollisionShape3D = $EnemyArea/CollisionShape3D
@onready var ball_collision_shape: CollisionShape3D = $BallSpawner/BallCollisionShape


@onready var ball_parent: Node3D = $BallParent

signal encounterFinished

var enemy = preload("res://scenes/Enemy/enemy.tscn")
var ball = preload("res://scenes/Ball/ball.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#FOR DEBUG ONLY
	# BALLS SHOULD SPAWN WHEN PLAYER WALKS INTO AREA
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_enemy_died() -> void:
	enemy_amount -= 1
	if enemy_amount <= 0:
		encounterFinished.emit()

func get_random_point_in_area(col: CollisionShape3D) -> Vector3:
	var local := Vector3.ZERO
	var shape = col.shape
	
	if shape is BoxShape3D:
		var half: Vector3 = shape.size * 0.5
		local = Vector3(
			randf_range(-half.x, half.x),
			0.0,
			randf_range(-half.z, half.z)
		)
	else:
		push_warning("Unsupported enemy area shape: %s. Should be BoxShape3D" % shape)
	
	return col.global_transform * local

func ball_destroyed() -> void:
	spawn_balls()
	

func spawn_balls() -> void:
	while ball_parent.get_child_count() < ball_amount:
		var ballInstance = ball.instantiate()
		ballInstance.ballDeath.connect(ball_destroyed)
		ballInstance.position = get_random_point_in_area(ball_collision_shape)
		ball_parent.add_child(ballInstance)
		print(ballInstance.get_groups())


func _on_player_walk_in_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		encounter_started = true
		spawn_balls()
		for i in range(enemy_amount):
			var enemyInstance = enemy.instantiate()
			enemyInstance.deadEnemySignal.connect(_on_enemy_died)
			enemyInstance.position = get_random_point_in_area(collision_shape_3d)
			add_child(enemyInstance)
