extends Enemy
class_name EnemyLife

@export var vida_maxima: int = 3

var vida_actual: int


func _ready() -> void:
	super._ready()
	vida_actual = vida_maxima

func hit() -> void:
	vida_actual -= 1
	enemy_damaged.emit(vida_actual, vida_maxima)

	
	if vida_actual <= 0:
		registrar_puntos()
		morir()
	else:
		recibir_golpe()
		
func recibir_golpe() -> void:
	var tween = create_tween()
	tween.tween_property(mesh, "modulate", Color(1, 0.3, 0.3), 0.05)
	tween.tween_property(mesh, "modulate", Color.WHITE, 0.15)
