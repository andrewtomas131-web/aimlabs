extends Enemy
class_name EnemyLife

@export var vida_maxima: int = 3

@onready var progress_bar = $SubViewport/ProgressBar

var vida_actual: int
var mat: StandardMaterial3D


func _ready() -> void:
	super._ready()
	vida_actual = vida_maxima
	# Verificamos si la malla tiene un material y hacemos una copia única
	if mesh.get_active_material(0):
		mat = mesh.get_active_material(0).duplicate()
		# Asignamos la copia única de vuelta al MeshInstance3D
		mesh.set_surface_override_material(0, mat)

func hit() -> void:
	vida_actual -= 1
	enemy_damaged.emit(vida_actual, vida_maxima)
	progress_bar.value -= 34.0
	
	if vida_actual <= 0:
		registrar_puntos()
		morir()
	else:
		recibir_golpe()
		
func recibir_golpe() -> void:
	Estadisticas.registrar_acierto(0)
	var tween = create_tween()
	var mat = mesh.get_active_material(0)
	if mat:
		tween.tween_property(mat, "albedo_color", Color(1, 0.3, 0.3), 0.05)
		tween.tween_property(mat, "albedo_color", Color.WHITE, 0.15)
