extends Enemy
class_name EnemyLife

@export var vida_maxima: int = 3

@export_group("Movimiento")
@export var movimiento_habilitado: bool = true
@export var velocidad_movimiento: float = 2.0
@export var amplitud_movimiento: float = 1.5

@onready var progress_bar = $SubViewport/ProgressBar

var vida_actual: int
var mat: StandardMaterial3D

var posicion_inicial: Vector3
var tiempo: float = 0.0
var fase: float = 0.0
var inicializada: bool = false

var direccion_movimiento: Vector3 = Vector3.ZERO


func _ready() -> void:
	super._ready()
	vida_actual = vida_maxima
	fase = randf() * TAU
	
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

	
func hit() -> void:
	vida_actual -= 1
	enemy_damaged.emit(vida_actual, vida_maxima)
	progress_bar.max_value = vida_maxima
	progress_bar.value = vida_actual
	
	if vida_actual <= 0:
		registrar_puntos()
		morir()
	else:
		recibir_golpe()

		
func recibir_golpe() -> void:
	Estadisticas.registrar_acierto(0)
	var tween = create_tween()
	if mat:
		tween.tween_property(mat, "albedo_color", Color(1, 0.3, 0.3), 0.05)
		tween.tween_property(mat, "albedo_color", Color.WHITE, 0.15)
