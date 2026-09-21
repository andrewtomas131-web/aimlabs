class_name Weapon
extends Node3D

@export var anim_fire: String = "Fire"
@export var anim_idle: String = "Iddle"
@export var anim_inspect: String = "Inspeecionar"
@export var fire_rate: float = 0.1 
@export var is_automatic:bool = false

@onready var anim_player: AnimationPlayer = find_child("AnimationPlayer", true, false)
@onready var shootRay = $Camera3D/ShootRay

signal hit_target

var fire_timer: float = 0.0
var is_firing:bool = false
var wants_to_fire: bool = false

func _ready() -> void:
	if not anim_player:
		push_warning("No se encontró AnimationPlayer")

func fire() -> void:
	wants_to_fire = true
	await start_fire()
	if not wants_to_fire:
		return
	shoot()
	is_firing = true
	play_anim_fire()
	
func _process(delta: float) -> void:
	if is_firing and is_automatic:
		fire_timer -= delta
		if fire_timer <= 0.0:
			fire_timer = fire_rate
			shoot()

func start_fire() -> void:
	anim_player.stop()

func play_anim_fire() -> void:
	anim_player.play(anim_fire)

func stop_fire() -> void:
	is_firing = false
	wants_to_fire = false

func inspect() -> void:
	if(!is_firing):
		anim_player.stop() 
		anim_player.play(anim_inspect)

func play_idle() -> void:
	if anim_player.current_animation != anim_fire and anim_player.current_animation != anim_inspect:
			anim_player.play(anim_idle)

func shoot() -> void:
	hit_target.emit()
	Estadisticas.registrar_disparo()
	if not shootRay.is_colliding():
		return
	var target = shootRay.get_collider()
	if target.is_in_group("target") and target.has_method("hit"):
		target.hit()
	else:
		return
