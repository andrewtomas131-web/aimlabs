extends Node

signal stats_changed

var puntuacion := 0
var disparos_totales := 0
var aciertos := 0


func registrar_disparo() -> void:
	disparos_totales += 1
	stats_changed.emit()

func registrar_acierto(puntos: int = 10) -> void:
	aciertos += 1
	puntuacion += puntos
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
