extends RigidBody3D
var reflected:= false
var thrower: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("ball")
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(8.0).timeout.connect(queue_free)

func _on_body_entered(body):
	if reflected and body.is_in_group("enemy"):
		 # -- damage --- 
		queue_free()
	elif not reflected and body.is_in_group("player"):
		# -- damage --
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
