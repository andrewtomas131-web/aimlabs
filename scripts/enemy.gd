extends Area3D

signal enemy_hit

@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var particles: GPUParticles3D = $GPUParticles3D
@onready var collision: CollisionShape3D = $CollisionShape3D

func _ready() -> void:
	add_to_group("target")

func hit() -> void:
	mesh.visible = false
	collision.disabled = true
	particles.emitting = true
	enemy_hit.emit()
	await get_tree().create_timer(particles.lifetime).timeout
	queue_free()
