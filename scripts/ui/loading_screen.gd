extends Control

@export var imagenes: Array[Texture2D] = []

@onready var imagen_fondo: TextureRect = $ImagenFondo
@onready var timer_imagenes: Timer = $TimerImagenes
@onready var barra: ProgressBar = $BarraCarga
@onready var label_porcentaje: Label = $LabelPorcentaje
@onready var label_tip: Label = $LabelTip

var indice_imagen := 0

var tips := [
	"Consejo: manten el crosshair a la altura de los ojos de tu objetivo.",
	"Consejo: la precision importa mas que la velocidad de disparo.",
	"Consejo: practica en Modo Normal antes de ir a Modo Enemigos.",
	"Consejo: ajusta tu sensibilidad en Configuracion para un mejor control del arma.",
	"Consejo: mira 'MEJOR PUNTAJE' en el menu para ver tu record.",
]


func _ready() -> void:
	label_tip.text = tips[randi() % tips.size()]
	ResourceLoader.load_threaded_request(GameSettings.escena_a_cargar)
	
	if imagenes.size() > 0:
		imagen_fondo.texture = imagenes[0]
	timer_imagenes.timeout.connect(_rotar_imagen)


func _rotar_imagen() -> void:
	if imagenes.is_empty():
		return
	indice_imagen = (indice_imagen + 1) % imagenes.size()
	imagen_fondo.texture = imagenes[indice_imagen]

func _process(_delta: float) -> void:
	var progreso_carga := []
	var estado := ResourceLoader.load_threaded_get_status(
		GameSettings.escena_a_cargar, progreso_carga
	)

	match estado:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if progreso_carga.size() > 0:
				var porcentaje: float = progreso_carga[0] * 100.0
				barra.value = porcentaje
				label_porcentaje.text = "%d%%" % int(porcentaje)

		ResourceLoader.THREAD_LOAD_LOADED:
			barra.value = 100
			label_porcentaje.text = "100%"
			var escena: PackedScene = ResourceLoader.load_threaded_get(
				GameSettings.escena_a_cargar
			)
			get_tree().change_scene_to_packed(escena)

		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			label_tip.text = "Ocurrio un error al cargar. Volviendo al menu..."
			await get_tree().create_timer(2.0).timeout
			get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
