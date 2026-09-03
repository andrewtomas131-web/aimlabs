extends Node3D

@onready var player = $Player
@onready var crosshair = $UI/Crosshair
@onready var crosshair_hit = $UI/Crosshair_hit


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
	
	crosshair.position = center - crosshair.size / 2.0
	crosshair_hit.position = center - crosshair.size / 2.0

func crosshair_hit_effect() -> void:
	crosshair.visible = false
	crosshair_hit.visible = true

	await get_tree().create_timer(0.2).timeout

	crosshair.visible = true
	crosshair_hit.visible = false
