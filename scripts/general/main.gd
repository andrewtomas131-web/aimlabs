extends Node3D


@onready var respawn_point = $Respawn

func _ready():
	#Comentado hasta que se active la logica para escoger el asset
	#var player_instance = GameSettings.selected_player_scene.instantiate()
	#player_instance.global_position = respawn_point.global_position
	#add_child(player_instance)
	pass
