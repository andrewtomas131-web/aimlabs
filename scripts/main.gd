extends Node3D
@onready var player = $Player
@onready var crosshair = $UI/Crosshair
@onready var crosshair_hit = $UI/Crosshair_hit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	crosshair.position.x = get_viewport().size.x /2 -64
	crosshair.position.y = get_viewport().size.y /2 -64
	crosshair_hit.position.x = get_viewport().size.x /2 -64
	crosshair_hit.position.y = get_viewport().size.y /2 -64
	
	# Al comenzar, mostramos el normal y ocultamos el de impacto
	crosshair.visible = true
	crosshair_hit.visible = false
	
	player.target_hit.connect(crosshair_hit_effect)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func crosshair_hit_effect() -> void:
	crosshair.visible = false
	crosshair_hit.visible = true
	
	await get_tree().create_timer(0.1).timeout
	
	crosshair.visible = true
	crosshair_hit.visible = false
