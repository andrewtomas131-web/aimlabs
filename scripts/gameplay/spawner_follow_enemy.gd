extends Area3D

@export var enemy_scene: PackedScene = preload("res://scenes/enemys/enemy_erratico.tscn")
@export var respawn_delay: float = 0.0
@export var enemies_container: NodePath

@onready var collision: CollisionShape3D = $CollisionShape3D2

var _container: Node
var _enemy_actual: Node


func _ready() -> void:
	if collision.shape == null:
		push_error("El CollisionShape3D no tiene un Shape asignado.")
		return

	# Igual que en spawn_targets: solo usamos el Area3D para calcular
	# posiciones y límites, no para colisionar físicamente.
	collision.disabled = true
	monitoring = false
	monitorable = false

	if enemies_container != NodePath():
		_container = get_node(enemies_container)
	else:
		_container = get_tree().current_scene

	call_deferred("spawn_enemy")


func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	_container.add_child(enemy)
	enemy.global_position = get_random_spawn_position()

	if enemy.has_method("configurar_area"):
		enemy.configurar_area(collision.shape, collision.global_transform)
	else:
		push_error("La escena instanciada no es un EnemyErratico (falta configurar_area). Script actual: %s" % enemy.get_script())

	if enemy.has_signal("enemy_hit"):
		enemy.enemy_hit.connect(_on_enemy_hit)
	else:
		push_error("El enemigo no tiene la señal 'enemy_hit'.")

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.cilindro_activo = enemy
	else:
		push_error("No se encontró un nodo en el grupo 'player'. ¿Está agregado con add_to_group('player')?")

	_enemy_actual = enemy


func _on_enemy_hit() -> void:
	_enemy_actual = null

	if respawn_delay > 0.0:
		await get_tree().create_timer(respawn_delay).timeout

	spawn_enemy()


func get_random_spawn_position() -> Vector3:
	var shape = collision.shape
	var pos: Vector3

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
		pos = global_position

	return pos
