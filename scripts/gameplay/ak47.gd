class_name AK47
extends Weapon

@export var recoil_pattern: Array[Vector2] = [
	Vector2(0, 0.7),
	Vector2(0.1, 1.2),
	Vector2(0.15, 1.7),
	Vector2(0.2, 2.0),
	Vector2(0.1, 2.2),
	Vector2(-0.1, 2.3),
	Vector2(-0.15, 2.5),
]

var shots_fired_in_burst: int = 0
var base_ray_rotation: Vector3


func _ready() -> void:
	super._ready()
	sonido_disparo = "disparo_rifle"
	base_ray_rotation = shootRay.rotation


func start_fire() -> void:
	anim_player.play("Fire_Start")

func play_anim_fire() -> void:
	anim_player.play(anim_fire, -1, 0.45)

func stop_fire() -> void:
	super.stop_fire()
	anim_player.play("Fire_Stop")

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
