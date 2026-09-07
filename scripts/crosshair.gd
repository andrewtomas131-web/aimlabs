extends CenterContainer
@export var DOT_RADIOUS: float = 1.0
@export var DOT_COLOR: Color = Color.WHITE
@export var CENTER = size/2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _draw() -> void:
	draw_circle(CENTER,DOT_RADIOUS,DOT_COLOR)
	
