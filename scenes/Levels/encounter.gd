extends Node3D

# The purpose of this script is to handle each encounter
# Each encounter should have at least one enemy
# And each encounter should have at least one ball active at all times.

@export var enemy_amount:= 1
@export var ball_amount:= 1
@export var enemy_area: Area3D
@onready var collision_shape_3d: CollisionShape3D = $EnemyArea/CollisionShape3D

signal encounterFinished

var enemy = preload("res://scenes/Enemy/enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(enemy_amount):
		var enemyInstance = enemy.instantiate()
		enemyInstance.deadEnemySignal.connect(_on_enemy_died)
		enemyInstance.position = get_random_point_in_area(collision_shape_3d)
		add_child(enemyInstance)
		
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
		push_warning("Unsupported enemy area shape. Should be BoxShape3D: %s" % shape)
	
	return col.global_transform * local
