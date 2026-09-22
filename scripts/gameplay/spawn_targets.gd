extends Area3D
@export var enemy_scene: PackedScene = preload("res://scenes/enemys/enemy.tscn")

@export var respawn_delay: float = 0.0
@export var max_enemies: int = 3
@export var enemies_container: NodePath
@export var min_distancia_entre_bolas: float = 2.0

# Distancia extra alrededor de las cajas (radio máximo de una esfera = 0.5 * 1.5)
const MARGEN_OBSTACULO: float = 0.8

@export var min_enemy_scale: float = 0.5
@export var normal_enemy_scale: float = 1.0
@export var max_enemy_scale: float = 1.5

@onready var collision: CollisionShape3D = $CollisionShape3D2

var active_enemies: Array[Node] = []
var _container: Node

func _ready() -> void:

	if collision.shape == null:

		push_error("El CollisionShape3D no tiene un Shape asignado.")

		return

	
	# Desactivamos la colisión física del spawner: solo la usamos
	# para calcular posiciones, no queremos que el raycast choque contra ella

	collision.disabled = true
	monitoring = false
	monitorable = false
	
	if enemies_container != NodePath():
		_container = get_node(enemies_container)
	else:
		_container = get_tree().current_scene

	
	for i in range(max_enemies):
		call_deferred("spawn_enemy")


func spawn_enemy() -> void:
	_actualizar_max_enemies()
	if active_enemies.size() >= max_enemies:
		return
	
	var enemy = enemy_scene.instantiate()
	_container.add_child(enemy)
	enemy.global_position = get_random_spawn_position()
	
	var datos = _elegir_escala_y_puntos()
	enemy.scale = Vector3.ONE * datos["escala"]
	enemy.set("puntos_base", datos["puntos_base"])
	
	if enemy.has_signal("enemy_hit"):
		enemy.enemy_hit.connect(_on_enemy_hit.bind(enemy))
	else:
		push_error("El enemigo no tiene la señal 'enemy_hit'. ¿Tiene asignado enemy.gd?")
	
	active_enemies.append(enemy)


func _on_enemy_hit(enemy: Node) -> void:
	if not active_enemies.has(enemy):
		return
	active_enemies.erase(enemy)
	
	if respawn_delay > 0.0:
		await get_tree().create_timer(respawn_delay).timeout
		
	spawn_enemy()
	spawn_enemy()

func get_random_spawn_position() -> Vector3:
	var shape = collision.shape
	var pos: Vector3
	var intentos = 0
	
	while true:
		if shape is BoxShape3D:
			var extents = shape.size / 2
			var offset = Vector3(
				randf_range(-extents.x, extents.x),
				randf_range(-extents.y, extents.y),
				randf_range(-extents.z, extents.z)
			)
			pos = global_position + global_transform.basis * offset
		
		elif shape is SphereShape3D:
			var radius = shape.radius
			var random_point = Vector3(
				randf_range(-1.0, 1.0),
				randf_range(-1.0, 1.0),
				randf_range(-1.0, 1.0)
			).normalized() * randf_range(0, radius)
			pos = global_position + random_point
		
		else:
			return global_position
		
		if (not _esta_muy_cerca(pos) and not _dentro_de_obstaculo(pos)) or intentos >= 30:
			return pos
		
		intentos += 1
	
	return pos

# Evita que las esferas aparezcan dentro de las cajas/escalones del mapa.
# Solo revisa nodos CSGBox3D del grupo "obstaculo" (si no hay, no hace nada).
func _dentro_de_obstaculo(pos: Vector3) -> bool:
	for nodo in get_tree().get_nodes_in_group("obstaculo"):
		if nodo is CSGBox3D:
			var local: Vector3 = nodo.global_transform.affine_inverse() * pos
			var mitad: Vector3 = nodo.size / 2.0 + Vector3.ONE * MARGEN_OBSTACULO
			if absf(local.x) <= mitad.x and absf(local.y) <= mitad.y and absf(local.z) <= mitad.z:
				return true
	return false

func _esta_muy_cerca(pos: Vector3) -> bool:
	for enemy in active_enemies:
		if is_instance_valid(enemy) and pos.distance_to(enemy.global_position) < min_distancia_entre_bolas:
			return true
	return false
	
func _elegir_escala_y_puntos() -> Dictionary:
	var categoria = randi_range(0, 2)  # 0=chica, 1=normal, 2=grande
	var escala: float
	var puntos_base: int
	
	match categoria:
		0:
			escala = randf_range(min_enemy_scale, normal_enemy_scale)
			puntos_base = 40
		1:
			escala = normal_enemy_scale
			puntos_base = 20
		2:
			escala = randf_range(normal_enemy_scale, max_enemy_scale)
			puntos_base = 10
	
	return {"escala": escala, "puntos_base": puntos_base}

func _actualizar_max_enemies() -> void:
	var nuevo_max = 3 + int(Estadisticas.puntuacion / 400)
	nuevo_max = min(nuevo_max, 12) 
	if nuevo_max > max_enemies:
		max_enemies = nuevo_max
