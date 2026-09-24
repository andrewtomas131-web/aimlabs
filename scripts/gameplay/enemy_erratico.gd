extends Enemy
class_name EnemyErratico

@export_group("Movimiento errático")
@export var velocidad_min: float = 10.0
@export var velocidad_max: float = 15.0
@export var tiempo_cambio_direccion_min: float = 0.7
@export var tiempo_cambio_direccion_max: float = 1.7
@export var variacion_vertical: float = 0.25

var disparos_consecutivos_sin_fallar: int = 0
var _area_shape: Shape3D
var _area_transform: Transform3D

var _direccion: Vector3 = Vector3.ZERO
var _tiempo_restante: float = 0.0
var _velocidad: float = 2.0

func _ready() -> void:
	super._ready() 
	_elegir_nueva_direccion()

func configurar_area(shape: Shape3D, area_global_transform: Transform3D) -> void:
	_area_shape = shape
	_area_transform = area_global_transform

func _process(delta: float) -> void:
	if _area_shape == null or esta_muerto:
		return
		
	_tiempo_restante -= delta
	if _tiempo_restante <= 0.0:
		_elegir_nueva_direccion()
		
	var nueva_pos: Vector3 = global_position + _direccion * _velocidad * delta

	if _dentro_del_area(nueva_pos):
		global_position = nueva_pos
	else:
		_elegir_nueva_direccion()

func _elegir_nueva_direccion() -> void:
	_direccion = Vector3(
		randf_range(-1.0, 1.0),
		randf_range(-variacion_vertical, variacion_vertical),
		randf_range(-1.0, 1.0)
	).normalized()
	_velocidad = randf_range(velocidad_min, velocidad_max)
	_tiempo_restante = randf_range(tiempo_cambio_direccion_min, tiempo_cambio_direccion_max)

func _dentro_del_area(pos: Vector3) -> bool:
	if _area_shape is BoxShape3D:
		var local: Vector3 = _area_transform.affine_inverse() * pos
		var mitad: Vector3 = _area_shape.size / 2.0
		return absf(local.x) <= mitad.x and absf(local.y) <= mitad.y and absf(local.z) <= mitad.z
	elif _area_shape is SphereShape3D:
		return pos.distance_to(_area_transform.origin) <= _area_shape.radius
	return true

func calcular_daño_recibido() -> int:
	return 20 

func _al_recibir_golpe() -> void:
	disparos_consecutivos_sin_fallar += 1
	_registrar_puntos_parciales()
	if particles:
		particles.restart()
	AudioManager.play("pop", -10.0, 0.08)

func registrar_fallo() -> void:
	disparos_consecutivos_sin_fallar = 0

func _registrar_puntos_parciales() -> void:
	var base_por_golpe = int(70.0 / max(scale.x, 0.001) / 25.0)
	var multiplicador_consistencia = clamp(1.0 + (disparos_consecutivos_sin_fallar / 25.0), 1.0, 2.0)
	Estadisticas.registrar_acierto(int(base_por_golpe * multiplicador_consistencia))
