extends Node

var puntuacion := 0
var disparos_totales := 0
var aciertos := 0

func registrar_disparo() -> void:
	disparos_totales += 1

func registrar_acierto(puntos: int = 10) -> void:
	aciertos += 1
	puntuacion += puntos

func porcentaje_aciertos() -> float:
	if disparos_totales == 0:
		return 0.0
	return (float(aciertos) / float(disparos_totales)) * 100.0
