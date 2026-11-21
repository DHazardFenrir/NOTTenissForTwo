extends Area2D

@export var moving := false
var direction := Vector2(1.0, 1.0)
var ball_speed := 300
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## Directions: up-right, down-right, down-left, up-left

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if moving:
		position += direction * ball_speed * delta
	
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PongPaddle"):
		direction.x *= -1
	elif not body.is_in_group("PongOut"):
		direction.y *= -1.0
	print(direction)
