extends Node3D

@export var damage := 10
@export var knockback := 8.0
@export var combo_reset_time := 0.6   # si tardas más, el combo vuelve al primer golpe

@onready var anim: AnimationPlayer = $"../AnimationPlayer"
@onready var hit_area: Area3D = $SM_Prop_Lute_01/Area3D
var combo := ["swing_derecha", "swing_arriba", "swing_izquierda"]
var combo_index := 0
var combo_timer := 0.0
var queued := false        # clic durante un swing = encadenar el siguiente
var blocking := false
var already_hit := []

func _ready():
	hit_area.monitoring = false
	hit_area.body_entered.connect(_on_hit)
	anim.animation_finished.connect(_on_anim_finished)

func _process(delta):
	if combo_index > 0 and not anim.is_playing():
		combo_timer -= delta
		if combo_timer <= 0:
			combo_index = 0

func _unhandled_input(event):
	if event.is_action_pressed("block"):
		blocking = true
		queued = false
		hit_area.monitoring = false
		anim.play("escudo")
	elif event.is_action_released("block"):
		blocking = false
		anim.play_backwards("escudo")
	elif event.is_action_pressed("attack") and not blocking:
		if anim.is_playing() and anim.current_animation in combo:
			queued = true
		else:
			_next_swing()

func _next_swing():
	already_hit.clear()
	anim.play(combo[combo_index])
	combo_index = (combo_index + 1) % combo.size()

func _on_anim_finished(anim_name: StringName):
	if anim_name in combo:
		if queued:
			queued = false
			_next_swing()
		else:
			combo_timer = combo_reset_time

func _on_hit(body: Node3D):
	if body in already_hit or body == owner:
		return
	already_hit.append(body)
	var dir := -global_basis.z
	if body is RigidBody3D:
		body.apply_central_impulse(dir * knockback)
	if body.has_method("take_damage"):
		body.take_damage(damage)
