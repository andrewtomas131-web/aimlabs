extends Node3D
@onready var crosshair = $UI/Crosshair

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	crosshair.position.x = get_viewport().size.x /2 -64
	crosshair.position.y = get_viewport().size.y /2 -64


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
