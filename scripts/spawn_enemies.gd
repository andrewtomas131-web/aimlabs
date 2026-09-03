extends Node3D

@export var enemy_scene: PackedScene
@export var respawn_delay := 0
@export var max_enemies := 3

var spawn_points: Array[Marker3D] = []
# Mapea cada enemigo activo -> el Marker3D donde está parado
var active_enemies: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is Marker3D:
			spawn_points.append(child)

	if spawn_points.is_empty():
		push_error("No se encontraron Marker3D.")
		return
	if enemy_scene == null:
		push_error("Enemy Scene no asignado en el Inspector.")
		return

	# Spawnea las 3 bolitas iniciales en puntos distintos
	for i in range(max_enemies):
		spawn_enemy()

func spawn_enemy(excluded_point: Marker3D = null) -> void:
	# No spawneas si ya llegaste al máximo
	if active_enemies.size() >= max_enemies:
		return

	# Recolecta solo los puntos que estén LIBRES y que NO sean el excluido
	var occupied := active_enemies.values()
	var available: Array[Marker3D] = []

	for point in spawn_points:
		if point == excluded_point:
			continue
		if not occupied.has(point):
			available.append(point)

	if available.is_empty():
		push_warning("No hay puntos de spawn disponibles.")
		return

	# Elige uno al azar entre los disponibles
	var point = available[randi() % available.size()]
	var enemy = enemy_scene.instantiate()
	add_child(enemy)
	enemy.global_position = point.global_position

	# Conecta la señal pasando la referencia del enemigo
	if enemy.has_signal("enemy_hit"):
		enemy.enemy_hit.connect(_on_enemy_hit.bind(enemy))
	else:
		push_error("El enemigo no tiene la señal 'enemy_hit'. ¿Tiene asignado enemy.gd?")

	active_enemies[enemy] = point

func _on_enemy_hit(enemy: Node) -> void:
	if not active_enemies.has(enemy):
		return

	var old_point = active_enemies[enemy]
	active_enemies.erase(enemy)
	

	# Pequeña pausa opcional (pon 0.0 si quieres instantáneo)
	if respawn_delay > 0.0:
		await get_tree().create_timer(respawn_delay).timeout

	# Spawnea la reemplazo, prohibiendo que use el punto donde estaba la eliminada
	spawn_enemy(old_point)
