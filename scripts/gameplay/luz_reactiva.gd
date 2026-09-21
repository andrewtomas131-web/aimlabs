extends Light3D

## Ejemplo vivo de "cambiar una propiedad de luz por código" (Sesión 17).
## Alterna light_color entre dos colores cada cierto tiempo, con Tween para
## que la transición se vea suave en vez de un salto brusco — la misma idea
## de Efectos.flash() de la Sesión 11, escrita aparte para no depender de
## esa clase en este proyecto.

@export var color_normal: Color = Color(0.753, 0.624, 0.467)
@export var color_alerta: Color = Color.BLACK
var rng = RandomNumberGenerator.new()


func _ready() -> void:
	var temporizador := Timer.new()
	var intervalo = rng.randf_range(.0, 3.0)
	temporizador.wait_time = intervalo
	temporizador.autostart = true
	add_child(temporizador)
	temporizador.timeout.connect(_parpadear)


func _parpadear() -> void:
	var tween := create_tween()
	tween.tween_property(self, "light_color", color_alerta, 1)
	tween.tween_property(self, "light_color", color_normal, 0.3)
