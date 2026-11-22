@tool
extends Marker3D

@export var tint := Color(0.6, 0.8, 1.0, 0.15):
	set(value):
		tint = value
		_apply_tint()

func _ready() -> void:
	_apply_tint()

func _apply_tint() -> void:
	if not is_inside_tree():
		return
	var mat := StandardMaterial3D.new()
	mat.albedo_color = tint
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	for csg in find_children("*", "CSGShape3D", true, false):
		if csg.is_root_shape():
			csg.material_overlay = mat
