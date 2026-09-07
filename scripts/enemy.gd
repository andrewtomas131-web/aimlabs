extends Area3D
signal enemy_hit

@onready var mesh: MeshInstance3D = $MeshInstance3D

@onready var particles: GPUParticles3D = $GPUParticles3D

@onready var collision: CollisionShape3D = $CollisionShape3D


var tiempo_spawn: int = 0



func _ready() -> void:
	
	add_to_group("target")
	tiempo_spawn = Time.get_ticks_msec()



func hit() -> void:
	
	
	var puntos_base = int(20 / scale.x)
	
	var tiempo_vivo = (Time.get_ticks_msec() - tiempo_spawn) / 1000.0
	
	var multiplicador = clamp(2.0 - (tiempo_vivo / 5.0), 0.5, 2.0)
	
	var puntos_finales = int(puntos_base * multiplicador)
	
	Estadisticas.registrar_acierto(puntos_finales)
	
	mesh.visible = false
	
	collision.disabled = true
	
	particles.emitting = true
	
	enemy_hit.emit()
	
	await get_tree().create_timer(particles.lifetime).timeout
	
	
	queue_free()
