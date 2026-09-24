extends Enemy
class_name EnemyLife

@export_group("Movimiento")
@export var movimiento_habilitado: bool = true
@export var velocidad_min: float = 1.7
@export var velocidad_max: float = 2.5
@export var amplitud_movimiento: float = 1.5

var mat: StandardMaterial3D
var velocidad_movimiento: float = 10.0
var posicion_inicial: Vector3
var tiempo: float = 0.0
var fase: float = 0.0
var inicializada: bool = false
var direccion_movimiento: Vector3 = Vector3.ZERO

func _ready() -> void:
	super._ready()
	fase = randf() * TAU
	velocidad_movimiento = randf_range(velocidad_min, velocidad_max)
	
	direccion_movimiento = global_transform.basis.y if randf() > 0.5 else global_transform.basis.z
	
	if mesh and mesh.get_active_material(0):
		mat = mesh.get_active_material(0).duplicate()
		mesh.set_surface_override_material(0, mat)

func _physics_process(delta: float) -> void:
	if esta_muerto or not movimiento_habilitado:
		return
		
	if not inicializada:
		posicion_inicial = global_position
		inicializada = true
	
	tiempo += delta
	var offset = sin(tiempo * velocidad_movimiento + fase) * amplitud_movimiento
	global_position = posicion_inicial + direccion_movimiento * offset

func _al_recibir_golpe() -> void:
	Estadisticas.registrar_acierto(0)
	if mat:
		var tween = create_tween()
		tween.tween_property(mat, "albedo_color", Color(1, 0.3, 0.3), 0.05)
		tween.tween_property(mat, "albedo_color", Color(0.0, 0.851, 0.788), 0.15)

# Sobreescribe la forma de dar puntos al morir definitivamente
func registrar_puntos(distancia: float = -1.0) -> void:
	var base = int(puntos_base / max(scale.x, 0.001))
	var multiplicador_velocidad = clamp(velocidad_movimiento / 2.0, 1.0, 2.5)
	var multiplicador_distancia = clamp(distancia / 10.0, 0.5, 2.0) if distancia > 0 else 1.0
	
	Estadisticas.registrar_acierto(int(base * multiplicador_velocidad * multiplicador_distancia))
