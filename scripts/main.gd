extends Node3D

@onready var player = $Player
@onready var crosshair = $UI/Crosshair
@onready var crosshair_hit = $UI/Crosshair_hit

# Reducir offset_x mueve la cruz a la DERECHA (30.0)
# Reducir offset_y mueve la cruz ABAJO (54.0)
@export var offset_x: float = 30.0
@export var offset_y: float = 50.0

func _ready() -> void:
	# Evita que las imágenes de la UI bloqueen el movimiento del mouse
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crosshair_hit.mouse_filter = Control.MOUSE_FILTER_IGNORE

	alinear_reticula()

	crosshair.visible = true
	crosshair_hit.visible = false

	player.target_hit.connect(crosshair_hit_effect)

func alinear_reticula() -> void:
	var screen_size = Vector2(get_viewport().size)
	var center = screen_size / 2.0
	
	var pos_final = Vector2(center.x - offset_x, center.y - offset_y)
	
	crosshair.position = pos_final
	crosshair_hit.position = pos_final

func crosshair_hit_effect() -> void:
	crosshair.visible = false
	crosshair_hit.visible = true

	await get_tree().create_timer(0.1).timeout

	crosshair.visible = true
	crosshair_hit.visible = false
