extends CenterContainer
@export var DOT_RADIOUS: float = 1.0
@export var DOT_COLOR: Color = Color.WHITE
@export var CENTER = size/2

func _draw() -> void:
	draw_circle(CENTER,DOT_RADIOUS,DOT_COLOR)
	
