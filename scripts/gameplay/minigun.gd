class_name MINIGUN
extends Weapon

@export var recoil_pattern: Array[Vector2] = [
	Vector2(0, 0.8),
	Vector2(0.1, 1.3),
	Vector2(0.15, 1.8),
	Vector2(0.2, 2.1),
	Vector2(0.1, 2.3),
	Vector2(-0.1, 2.4),
	Vector2(-0.15, 2.5),
]

@export var base_spread: float = 0.3
@export var max_spread: float = 4.0
@export var spread_increase_per_shot: float = 0.25

var shots_fired_in_burst: int = 0
var base_ray_rotation: Vector3

func _ready() -> void:
	super._ready()
	base_ray_rotation = shootRay.rotation

func start_fire() -> void:
	anim_player.play("rig|rig|Fire_Start")
	await anim_player.animation_finished

func stop_fire() -> void:
	super.stop_fire()
	anim_player.play("rig|rig|Fire_Stop")
	
func play_idle() -> void:
	if anim_player.current_animation not in ["rig|rig|Fire_Stop", "rig|rig|Fire_Start", "rig|rig|Fire", "rig|rig|Inspect"]:
		anim_player.play(anim_idle)

func emit_recoil() -> void:
	if recoil_pattern.is_empty():
		return
	var offset = recoil_pattern[min(shots_fired_in_burst, recoil_pattern.size() - 1)]
	recoil_kick.emit(offset)
	shots_fired_in_burst += 1

func play_walk() -> void:
	anim_player.play(anim_walk)

func reset_burst() -> void:
	shots_fired_in_burst = 0
