extends Node

signal stats_changed

const STATS_PATH := "user://estadisticas.cfg"

var puntuacion := 0
var disparos_totales := 0
var aciertos := 0
var mejor_puntuacion := 0              
var mejores_por_modo: Dictionary = {}  
var modo_actual: String = ""           


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

	if modo_actual != "":
		var mejor_modo: int = mejores_por_modo.get(modo_actual, 0)
		if puntuacion > mejor_modo:
			mejores_por_modo[modo_actual] = puntuacion
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

func mejor_puntaje_de(escena_path: String) -> int:
	return mejores_por_modo.get(escena_path, 0)

func guardar_mejor_puntuacion() -> void:
	var config := ConfigFile.new()
	config.load(STATS_PATH)
	config.set_value("puntuacion", "mejor", mejor_puntuacion)
	for escena in mejores_por_modo:
		config.set_value("mejor_por_modo", escena, mejores_por_modo[escena])
	config.save(STATS_PATH)

func cargar_mejor_puntuacion() -> void:
	var config := ConfigFile.new()
	if config.load(STATS_PATH) == OK:
		mejor_puntuacion = config.get_value("puntuacion", "mejor", 0)
		if config.has_section("mejor_por_modo"):
			for clave in config.get_section_keys("mejor_por_modo"):
				mejores_por_modo[clave] = config.get_value("mejor_por_modo", clave, 0)
