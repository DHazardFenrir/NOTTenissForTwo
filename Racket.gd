extends Node3D

var reset_pos: Vector3
var reset_rot: Vector3
var tween : Tween
var busy:= false
var blocking:= false
var next_is_reverse:= false

func _ready():
	reset_pos = position
	reset_rot = rotation_degrees
	print("Racket Ready", reset_pos)

func _unhandled_input(event):
	if event is InputEventMouseButton:

		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not busy and not blocking:
				if next_is_reverse:
					reverse()
				else:
					swing()
				next_is_reverse = not next_is_reverse


		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				shield_up()
			else:
				shield_down()


func swing():
	busy = true
	new_tween()
	add_step(Vector3(0.1,0.1,0.15), Vector3(0,-40,60),0.10)
	add_step(Vector3(-0.5,0.1,0.0), Vector3(0,90,60),0.14)
	add_step(Vector3.ZERO, Vector3.ZERO, 0.2)
	tween.tween_callback(func():busy=false)

func reverse():
	busy = true
	new_tween()
	add_step(Vector3(-0.6, 0.1, 0.15), Vector3(0, 40, 60), 0.10)    
	add_step(Vector3(0.0, 0.1, 0.0), Vector3(0, -90, 60), 0.14)     
	add_step(Vector3.ZERO, Vector3.ZERO, 0.2)                     
	tween.tween_callback(func(): busy = false)

func shield_up():
	blocking = true
	busy = false
	new_tween()
	add_step(Vector3(-0.3,0.25,0.0), Vector3(0,0,90),0.1)

func shield_down():
	blocking = false
	new_tween()
	add_step(Vector3.ZERO, Vector3.ZERO, 0.12)
	
func add_step(pos_off: Vector3, rot_off:Vector3, time:float):
	tween.tween_property(self, "position",reset_pos +pos_off, time)
	tween.parallel().tween_property(self, "rotation_degrees", reset_rot+rot_off, time)

func new_tween():
	if tween:
		tween.kill()
	tween = create_tween()
