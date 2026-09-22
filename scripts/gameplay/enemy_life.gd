extends Enemy
class_name EnemyLife

@export var vida_maxima: int = 3

@export_group("Movimiento")
@export var movimiento_habilitado: bool = true
@export var velocidad_min: float = 2.0
@export var velocidad_max: float = 3.5
@export var amplitud_movimiento: float = 1.5

@onready var progress_bar = $SubViewport/ProgressBar

var vida_actual: int
var mat: StandardMaterial3D
var velocidad_movimiento: float = 10.0

var posicion_inicial: Vector3
var tiempo: float = 0.0
var fase: float = 0.0
var inicializada: bool = false

var direccion_movimiento: Vector3 = Vector3.ZERO


func _ready() -> void:
	super._ready()
	vida_actual = vida_maxima
	fase = randf() * TAU
	
	velocidad_movimiento = randf_range(velocidad_min, velocidad_max)
	
	if randf() > 0.5:
		direccion_movimiento = global_transform.basis.y
	else:
		direccion_movimiento = global_transform.basis.z
	
	# Verificamos si la malla tiene un material y hacemos una copia única
	if mesh.get_active_material(0):
		mat = mesh.get_active_material(0).duplicate()
		# Asignamos la copia única de vuelta al MeshInstance3D
		mesh.set_surface_override_material(0, mat)

	
func _physics_process(delta: float) -> void:
	if not movimiento_habilitado:
		return
		
	if not inicializada:
		posicion_inicial = global_position
		inicializada = true
	
	tiempo += delta
	var offset = sin(tiempo * velocidad_movimiento + fase) * amplitud_movimiento
	
	global_position = posicion_inicial + direccion_movimiento * offset

	
func hit(distancia: float = -1.0) -> void:	
	vida_actual -= 1
	enemy_damaged.emit(vida_actual, vida_maxima)
	progress_bar.max_value = vida_maxima
	progress_bar.value = vida_actual
	
	if vida_actual <= 0:
		registrar_puntos(distancia)
		morir()
		progress_bar.visible = false
	else:
		recibir_golpe()

func registrar_puntos(distancia: float = -1.0) -> void:
	var base = int(puntos_base / scale.x)
	var multiplicador_velocidad = clamp(velocidad_movimiento / 2.0, 1.0, 2.5)
	var multiplicador_distancia = clamp(distancia / 10.0, 0.5, 2.0) if distancia > 0 else 1.0
	
	var puntos_finales = int(base * multiplicador_velocidad * multiplicador_distancia)
	Estadisticas.registrar_acierto(puntos_finales)

func recibir_golpe() -> void:
	AudioManager.play("golpe_enemigo", -5.0, 0.06)
	Estadisticas.registrar_acierto(0)
	var tween = create_tween()
	if mat:
		tween.tween_property(mat, "albedo_color", Color(1, 0.3, 0.3), 0.05)
		tween.tween_property(mat, "albedo_color", Color(0.0, 0.851, 0.788), 0.15)
