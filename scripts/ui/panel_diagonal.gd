extends Control

@export var color := Color("#080b0dcc")
@export var edge_color := Color("#47D8D7")
@export var edge_width := 3.0


func _draw():
	var w = size.x
	var h = size.y

	var puntos = PackedVector2Array([
		Vector2(0, 0),
		Vector2(w * 0.67, 0),
		Vector2(w * 0.56, h),
		Vector2(0, h)
	])

	draw_colored_polygon(puntos, color)

	draw_line(
		Vector2(w * 0.67, 0),
		Vector2(w * 0.56, h),
		edge_color,
		edge_width
	)
