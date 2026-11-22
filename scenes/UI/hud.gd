extends CanvasLayer
@onready var icon_timer: Timer = $iconTimer
@onready var character_icon: TextureRect = $TextureRect3/characterIcon
@onready var character_icon_hurting: TextureRect = $TextureRect3/characterIconHurting
@onready var character_icon_hurt: TextureRect = $TextureRect3/characterIconHurt

var hurt = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	character_icon.visible = true
	character_icon_hurting.visible = false
	character_icon_hurt.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_player_hurt() -> void:
	character_icon.visible = false
	character_icon_hurting.visible = true
	character_icon_hurt.visible = false
	icon_timer.start()

func _on_icon_timer_timeout() -> void:
	character_icon.visible = false
	character_icon_hurting.visible = false
	character_icon_hurt.visible = true
