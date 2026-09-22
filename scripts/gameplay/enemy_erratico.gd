extends Enemy
class_name EnemyErratico


@onready var progress_bar = $SubViewport/ProgressBar


@export var vida_maxima: int = 500

@export_group("Movimiento errático")
@export var velocidad_min: float = 3.5
@export var velocidad_max: float = 5.5
@export var tiempo_cambio_direccion_min: float = 0.5
@export var tiempo_cambio_direccion_max: float = 1.5
@export var variacion_vertical: float = 0.25  # 0 = solo se mueve en el plano XZ

var vida_actual: int

# Asignados por el spawner con configurar_area()
var _area_shape: Shape3D
var _area_transform: Transform3D

var _direccion: Vector3 = Vector3.ZERO
var _velocidad: float = 2.0
var _tiempo_restante: float = 0.0


func _ready() -> void:
	super._ready()
	vida_actual = vida_maxima
	_elegir_nueva_direccion()


func configurar_area(shape: Shape3D, area_global_transform: Transform3D) -> void:
	_area_shape = shape
	_area_transform = area_global_transform


func _process(delta: float) -> void:
	if _area_shape == null:
		return

	_tiempo_restante -= delta
	if _tiempo_restante <= 0.0:
		_elegir_nueva_direccion()

	var nueva_pos: Vector3 = global_position + _direccion * _velocidad * delta

	if _dentro_del_area(nueva_pos):
		global_position = nueva_pos
	else:
		# Chocó con el límite del área: elige otra dirección de inmediato
		# en vez de quedarse pegado al borde.
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


# Sobrescribe el hit() de Enemy: ahora hace falta más de un disparo para morir.
func hit() -> void:
	vida_actual -= 20
	enemy_damaged.emit(vida_actual, vida_maxima)
	progress_bar.max_value = vida_maxima
	progress_bar.value = vida_actual

	if vida_actual <= 0:
		registrar_puntos()
		morir()
		progress_bar.visible = false
	else:
		_feedback_golpe()

func _feedback_golpe() -> void:
	if particles:
		particles.emitting = true
