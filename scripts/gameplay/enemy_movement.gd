extends Enemy
class_name EnemyMovement

@export_group("Movimiento")
const DISTANCIA_MAXIMA_UTIL: float = 30.0
@export var movimiento_habilitado: bool = true
@export var velocidad_min: float = 2.0
@export var velocidad_max: float = 2.7
@export var amplitud_movimiento: float = 1.5

var velocidad_movimiento: float = 2.0
var posicion_inicial: Vector3
var tiempo: float = 0.0
var fase: float = 0.0
var inicializada: bool = false

var direccion_movimiento: Vector3 = Vector3.ZERO

func _ready() -> void:
	super._ready()
	fase = randf() * TAU
	velocidad_movimiento = randf_range(velocidad_min, velocidad_max)
	
	if randf() > 0.5:
		direccion_movimiento = global_transform.basis.y
	else:
		direccion_movimiento = global_transform.basis.x

# Cambiado a _physics_process para mejor rendimiento con colisiones Area3D
func _physics_process(delta: float) -> void:
	if esta_muerto or not movimiento_habilitado:
		return
		
	if not inicializada:
		posicion_inicial = global_position
		inicializada = true
	
	tiempo += delta
	var offset = sin(tiempo * velocidad_movimiento + fase) * amplitud_movimiento
	global_position = posicion_inicial + direccion_movimiento * offset

func registrar_puntos(distancia: float = -1.0) -> void:
	var base = int(puntos_base / max(scale.x, 0.001))
	var multiplicador_velocidad = clamp(velocidad_movimiento / velocidad_min, 1.0, 2.5)
	var dist_calculo = min(distancia, DISTANCIA_MAXIMA_UTIL) if distancia > 0 else 1.0
	var multiplicador_distancia = clamp(dist_calculo / 15.0, 0.5, 2.0)
	
	var puntos_finales = int(base * multiplicador_velocidad * multiplicador_distancia)
	Estadisticas.registrar_acierto(puntos_finales)
