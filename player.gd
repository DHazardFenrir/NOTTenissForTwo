extends CharacterBody3D


const SPEED = 5.0
const GRAVITY = 20
const SENSITIVITY = 0.005
@onready var head = $Head
@onready var cam = $Head/Camera3D


func _physics_process(delta: float) -> void:
	var dir:= Vector3.ZERO
	dir.x = Input.get_axis("left", "right")
	
	dir.z = Input.get_axis("up", "down")
	dir = dir.normalized()
	velocity.x = dir.x * SPEED
	velocity.z = dir.z * SPEED
	
	if not is_on_floor():
		velocity.y-= GRAVITY * delta


	

	move_and_slide()
	
