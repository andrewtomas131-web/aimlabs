class_name Weapon
extends Node3D

const SHOOT_DISTANCE = 10000.0

@onready var anim_player: AnimationPlayer = find_child("AnimationPlayer", true, false)
@onready var shootRay: RayCast3D = $Camera3D/ShootRay # ajusta la ruta según dónde quede dentro del arma

signal hit_target  # para avisarle al Player que muestre el crosshair_hit

func _ready() -> void:
	if not anim_player:
		push_warning("No se encontró AnimationPlayer")

func fire() -> void:
	anim_player.stop()
	anim_player.play("Fire")
	shoot()

func inspect() -> void:
	anim_player.stop()
	anim_player.play("Inspeecionar")

func play_idle() -> void:
	if anim_player and anim_player.current_animation != "Fire" and anim_player.current_animation != "Inspeecionar":
		anim_player.play("Iddle")

func shoot() -> void:
	Estadisticas.registrar_disparo()
	if not shootRay.is_colliding():
		return
	var target = shootRay.get_collider()
	if target.is_in_group("target") and target.has_method("hit"):
		target.hit()
		hit_target.emit()
