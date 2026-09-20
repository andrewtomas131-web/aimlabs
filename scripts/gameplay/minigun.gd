class_name MINIGUN
extends Weapon

@export var recoil_pattern: Array[Vector2] = []
var shots_fired_in_burst: int = 0


func start_fire() -> void:
	anim_player.play("rig|Fire_Start")
	await anim_player.animation_finished

func stop_fire() -> void:
	super.stop_fire()
	anim_player.play("rig|Fire_Stop")
	
func play_idle() -> void:
	if anim_player.current_animation not in ["rig|Fire_Stop", "rig|Fire_Start", "rig|Fire", "rig|Inspect"]:
		anim_player.play(anim_idle)

func reset_burst() -> void:
	shots_fired_in_burst = 0
