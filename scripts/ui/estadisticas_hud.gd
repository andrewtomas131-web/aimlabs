extends HBoxContainer

@onready var label_puntos: Label = $PanelPuntos/VBoxPuntos/LabelPuntosValor
@onready var label_precision: Label = $PanelPrecision/VBoxPrecision/LabelPrecisionValor


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	Estadisticas.stats_changed.connect(_actualizar_ui)
	_actualizar_ui()

func _actualizar_ui() -> void:
	label_puntos.text = str(Estadisticas.puntuacion)
	label_precision.text = "%.1f%%" % Estadisticas.porcentaje_aciertos()
