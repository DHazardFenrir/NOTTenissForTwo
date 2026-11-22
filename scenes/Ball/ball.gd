extends RigidBody3D
var reflected:= false
var thrower: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("ball")
	body_entered.connect(_on_body_entered)
	#get_tree().create_timer(8.0).timeout.connect(queue_free)

func _on_body_entered(body):
	#print("Entering ", body.name)
	#if body.is_in_group("Actors"):
		#print(body)
		#var away = global_position - body.global_position
		#print(away)
		#var direction = away.normalized()
		#apply_central_impulse(direction * 1)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
