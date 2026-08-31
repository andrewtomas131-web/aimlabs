extends Area3D

signal enemy_hit

func _ready() -> void:
	add_to_group("target")

func hit() -> void:
	enemy_hit.emit()
	queue_free()
