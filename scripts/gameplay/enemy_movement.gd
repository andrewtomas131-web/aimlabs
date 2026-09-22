extends Enemy
class_name EnemyMovement

@export_group("Movimiento")
@export var movimiento_habilitado: bool = true
@export var velocidad_movimiento: float = 2.2
@export var amplitud_movimiento: float = 1.5

var posicion_inicial: Vector3
var tiempo: float = 0.0
var fase: float = 0.0
var inicializada: bool = false

var direccion_movimiento: Vector3 = Vector3.ZERO

func _ready() -> void:
	super._ready()
	fase = randf() * TAU

	if randf() > 0.5:
		direccion_movimiento = global_transform.basis.y
	else:
		direccion_movimiento = global_transform.basis.z


func _process(delta: float) -> void:
	if not movimiento_habilitado:
		return
		
	if not inicializada:
		posicion_inicial = global_position
		inicializada = true
	
	tiempo += delta
	var offset = sin(tiempo * velocidad_movimiento + fase) * amplitud_movimiento
	
	global_position = posicion_inicial + direccion_movimiento * offset

func hit() -> void:
	super.hit()
