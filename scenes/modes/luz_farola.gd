extends Light3D

@export var energia_reposo: float = 0.0
@export var energia_pico: float = 16.0

@export var tiempo_minimo: float = 0.0
@export var tiempo_maximo: float = 10.0

var temporizador: Timer


func _ready() -> void:
	light_energy = energia_reposo
	
	temporizador = Timer.new()
	temporizador.one_shot = true
	add_child(temporizador)
	temporizador.timeout.connect(_parpadear_farola)
	
	_reiniciar_temporizador()


func _parpadear_farola() -> void:
	var tween := create_tween()
	
	tween.tween_property(self, "light_energy", energia_pico, 0.05)
	tween.tween_property(self, "light_energy", energia_pico * 0.2, 0.03)
	tween.tween_property(self, "light_energy", energia_pico, 0.04)
	tween.tween_property(self, "light_energy", 0.0, 0.08)
	tween.tween_property(self, "light_energy", energia_pico, 0.05)
	tween.tween_interval(2.0)
	tween.tween_property(self, "light_energy", energia_pico * 0.4, 0.04)
	tween.tween_property(self, "light_energy", energia_reposo, 0.1)
	
	tween.finished.connect(_reiniciar_temporizador)


func _reiniciar_temporizador() -> void:
	var intervalo := randf_range(tiempo_minimo, tiempo_maximo)
	temporizador.start(intervalo)
