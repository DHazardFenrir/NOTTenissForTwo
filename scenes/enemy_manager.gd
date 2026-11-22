extends Node3D

@export var player: CharacterBody3D
@export var enemy1: CharacterBody3D
@export var enemy2: CharacterBody3D
@export var enemy3: CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy1.deadEnemySignal.connect(_on_enemy_died)
	enemy2.deadEnemySignal.connect(_on_enemy_died)
	enemy3.deadEnemySignal.connect(_on_enemy_died)
	pass # Replace with function body.

func _on_enemy_died() -> void:
	player.unlock()
