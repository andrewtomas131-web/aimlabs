extends Area3D

const ENEMY_SCENE: PackedScene = preload("res://scenes/enemy.tscn")

@export var respawn_delay: float = 0.0
@export var max_enemies: int = 3
@export var enemies_container: NodePath

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
	if active_enemies.size() >= max_enemies:
		return
	
	var enemy = ENEMY_SCENE.instantiate()
	_container.add_child(enemy)
	enemy.global_position = get_random_spawn_position()
	
	if enemy.has_signal("enemy_hit"):
		enemy.enemy_hit.connect(_on_enemy_hit.bind(enemy))
	else:
		push_error("El enemigo no tiene la señal 'enemy_hit'. ¿Tiene asignado enemy.gd?")
	
	active_enemies.append(enemy)
	print("Enemigo spawneado en: ", enemy.global_position)

func _on_enemy_hit(enemy: Node) -> void:
	if not active_enemies.has(enemy):
		return
	active_enemies.erase(enemy)
	
	if respawn_delay > 0.0:
		await get_tree().create_timer(respawn_delay).timeout
	
	spawn_enemy()

func get_random_spawn_position() -> Vector3:
	var shape = collision.shape
	
	if shape is BoxShape3D:
		var extents = shape.size / 2
		var offset = Vector3(
			randf_range(-extents.x, extents.x),
			randf_range(-extents.y, extents.y),
			randf_range(-extents.z, extents.z)
		)
		return global_position + global_transform.basis * offset
	
	elif shape is SphereShape3D:
		var radius = shape.radius
		var random_point = Vector3(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		).normalized() * randf_range(0, radius)
		return global_position + random_point
	return global_position
