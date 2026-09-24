extends Area3D
class_name Enemy

signal enemy_hit
signal enemy_damaged(vida_restante: int, vida_maxima: int)

@export var vida_maxima: int = 1
@export var puntos_base: int = 20

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var progress_bar: ProgressBar = find_child("ProgressBar", true, false)

var vida_actual: int
var tiempo_spawn: int = 0
var esta_muerto: bool = false

func _ready() -> void:
	add_to_group("target")
	tiempo_spawn = Time.get_ticks_msec()
	vida_actual = vida_maxima
	_actualizar_ui_vida()

# Plantilla para cuando recibe un disparo
func hit(distancia: float = -1.0) -> void:
	if esta_muerto:
		return
		
	var daño = calcular_daño_recibido()
	aplicar_daño(daño, distancia)

func aplicar_daño(cantidad: int, distancia: float = -1.0) -> void:
	vida_actual = max(0, vida_actual - cantidad)
	enemy_damaged.emit(vida_actual, vida_maxima)
	_actualizar_ui_vida()

	if vida_actual <= 0:
		registrar_puntos(distancia)
		morir()
	else:
		_al_recibir_golpe()


func calcular_daño_recibido() -> int:
	return 1

func _al_recibir_golpe() -> void:
	pass

func registrar_puntos(distancia: float = -1.0) -> void:
	var base = int(puntos_base / max(scale.x, 0.001))
	var tiempo_vivo = (Time.get_ticks_msec() - tiempo_spawn) / 1000.0
	var multiplicador = clamp(2.0 - (tiempo_vivo / 5.0), 0.5, 2.0)
	Estadisticas.registrar_acierto(int(base * multiplicador))

func morir() -> void:
	esta_muerto = true
	mesh.visible = false
	collision.disabled = true
	if progress_bar:
		progress_bar.visible = false
		
	if particles:
		particles.emitting = true
		
	enemy_hit.emit()
	AudioManager.play("pop", -3.0, 0.08)
	
	var tiempo_espera = particles.lifetime if particles else 0.1
	await get_tree().create_timer(tiempo_espera).timeout
	queue_free()

func _actualizar_ui_vida() -> void:
	if progress_bar:
		progress_bar.max_value = vida_maxima
		progress_bar.value = vida_actual
