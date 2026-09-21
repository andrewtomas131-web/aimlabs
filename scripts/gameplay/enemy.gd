extends Area3D
class_name Enemy

signal enemy_hit
signal enemy_damaged(vida_restante: int, vida_maxima: int)

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var collision: CollisionShape3D = $CollisionShape3D


var tiempo_spawn: int = 0
var puntos_base: int = 20



func _ready() -> void:
	
	add_to_group("target")
	tiempo_spawn = Time.get_ticks_msec()



func hit() -> void:
	registrar_puntos()
	morir()
	
	
func registrar_puntos() -> void:
	var base = int(puntos_base/scale.x)
	var tiempo_vivo = (Time.get_ticks_msec() - tiempo_spawn) / 1000.0
	var multiplicador = clamp(2.0 - (tiempo_vivo / 5.0), 0.5, 2.0)
	var puntos_finales = int(base * multiplicador)
	
	Estadisticas.registrar_acierto(puntos_finales)

func morir() -> void:
	mesh.visible = false
	collision.disabled = true
	particles.emitting = true
	enemy_hit.emit()
	
	await get_tree().create_timer(particles.lifetime).timeout
	queue_free()
