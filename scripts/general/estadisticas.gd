extends Node

signal stats_changed
const STATS_PATH := "user://estadisticas.cfg"

var puntuacion := 0
var disparos_totales := 0
var aciertos := 0
var mejor_puntuacion := 0

func _ready() -> void:
	cargar_mejor_puntuacion()

func registrar_disparo() -> void:
	disparos_totales += 1
	stats_changed.emit()

func registrar_acierto(puntos: int = 10) -> void:
	aciertos += 1
	puntuacion += puntos
	if puntuacion > mejor_puntuacion:
		mejor_puntuacion = puntuacion
		guardar_mejor_puntuacion()
	stats_changed.emit()

func porcentaje_aciertos() -> float:
	if disparos_totales == 0:
		return 0.0
	return (float(aciertos) / float(disparos_totales)) * 100.0

func reset() -> void:
	puntuacion = 0
	disparos_totales = 0
	aciertos = 0
	stats_changed.emit()
	
func guardar_mejor_puntuacion() -> void:
	var config := ConfigFile.new()
	config.load(STATS_PATH)
	config.set_value("puntuacion", "mejor", mejor_puntuacion)
	config.save(STATS_PATH)

func cargar_mejor_puntuacion() -> void:
	var config := ConfigFile.new()
	if config.load(STATS_PATH) == OK:
		mejor_puntuacion = config.get_value("puntuacion", "mejor", 0)
