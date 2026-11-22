extends RigidBody3D
var reflected:= false
var thrower: Node3D
@onready var bounce: AudioStreamPlayer3D = $Bounce

@export var damage:= 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

signal ballDeath

func ball_death() -> void:
	if is_queued_for_deletion():
		return
	queue_free()       # mark as dying FIRST
	ballDeath.emit()


func _on_body_entered(body: Node) -> void:
	bounce.play()
