class_name AK47
extends Weapon

@export var recoil_pattern: Array[Vector2] = []
var shots_fired_in_burst: int = 0

func _ready() -> void:
	pass

func start_fire() -> void:
	anim_player.play("Fire_Start")

func play_anim_fire() -> void:
	anim_player.play(anim_fire, -1, 0.45)

func stop_fire() -> void:
	super.stop_fire()
	anim_player.play("Fire_Stop")

func reset_burst() -> void:
	shots_fired_in_burst = 0
