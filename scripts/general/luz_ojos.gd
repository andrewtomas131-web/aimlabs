extends Node3D

@export var energia_reposo: float = 0.0
@export var energia_pico: float = 16.0

@export var tiempo_minimo: float = 1.0
@export var tiempo_maximo: float = 30.0

var temporizador: Timer
var luces: Array[Light3D] = []


func _ready() -> void:
	for hijo in find_children("*", "Light3D", true, false):
		if hijo is Light3D:
			luces.append(hijo)
			hijo.light_energy = energia_reposo
			
	if luces.is_empty():
		push_warning("No se encontraron nodos Light3D dentro de este Node3D")

	temporizador = Timer.new()
	temporizador.one_shot = true
	add_child(temporizador)
	
	temporizador.timeout.connect(_destellar_todas)
	
	_reiniciar_temporizador_aleatorio()

func _destellar_todas() -> void:
	var tween := create_tween()

	for i in luces.size():
		var luz := luces[i]
		if i == 0:
			tween.tween_property(luz, "light_energy", energia_pico, 0.1)
		else:
			tween.parallel().tween_property(luz, "light_energy", energia_pico, 0.1)
			
	tween.tween_interval(5.0)
	
	for i in luces.size():
		var luz := luces[i]
		if i == 0:
			tween.tween_property(luz, "light_energy", energia_reposo, 0.1)
		else:
			tween.parallel().tween_property(luz, "light_energy", energia_reposo, 0.1)
		
	tween.finished.connect(_reiniciar_temporizador_aleatorio)

func _reiniciar_temporizador_aleatorio() -> void:
	var tiempo_espera := randf_range(tiempo_minimo, tiempo_maximo)
	temporizador.start(tiempo_espera)
