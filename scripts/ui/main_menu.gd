extends Control


func _ready() -> void:
	$MenuContent/PanelConfiguracion/SliderSensibilidad.value = GameSettings.mouse_sensitivity
	$MenuContent/PanelConfiguracion/CheckPantallaCompleta.button_pressed = GameSettings.fullscreen
	$MenuContent/PanelConfiguracion/ValorSensibilidad.text = "%.3f" % GameSettings.mouse_sensitivity
	aplicar_pantalla_completa()
	
func aplicar_pantalla_completa() -> void:
	if GameSettings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# --- NAVEGACIÓN Y MENÚS ---

func _on_btn_jugar_pressed() -> void:
	$MenuContent/PanelModos.visible = true
	_actualizar_mejores_modos()

func _on_btn_volver_modos_pressed() -> void:
	$MenuContent/PanelModos.visible = false

func _on_btn_configuracion_pressed() -> void:
	$MenuContent/PanelConfiguracion.visible = true

func _on_btn_volver_pressed() -> void:
	$MenuContent/PanelConfiguracion.visible = false

func _on_btn_ayuda_pressed() -> void:
	$PanelAyuda.visible = true

func _on_btn_entendido_pressed() -> void:
	$PanelAyuda.visible = false


# --- SELECCIÓN DE MODOS DE JUEGO ---

func _on_btn_modo_normal_pressed() -> void:
	_iniciar_modo("res://scenes/modes/main.tscn")

func _on_btn_modo_enemigos_pressed() -> void:
	_iniciar_modo("res://scenes/modes/modo_enemys.tscn")

func _on_btn_modo_enemys_life_pressed() -> void:
	_iniciar_modo("res://scenes/modes/modo_enemys_life.tscn")

func _on_btn_modo_follow_enemy_pressed() -> void:
	_iniciar_modo("res://scenes/modes/modo_follow_enemy.tscn")

func _iniciar_modo(ruta_escena: String) -> void:
	Estadisticas.reset()
	Estadisticas.modo_actual = ruta_escena
	GameSettings.escena_a_cargar = ruta_escena
	get_tree().change_scene_to_file("res://scenes/ui/loading_screen.tscn")

func _actualizar_mejores_modos() -> void:
	$MenuContent/PanelModos/GridModos/TarjetaModoNormal/VBoxContainer/MejorPuntajeModo.text = \
		"Mejor: %d" % Estadisticas.mejor_puntaje_de("res://scenes/modes/main.tscn")
	$MenuContent/PanelModos/GridModos/TarjetaModoEnemigos/VBoxContainer/MejorPuntajeModo.text = \
		"Mejor: %d" % Estadisticas.mejor_puntaje_de("res://scenes/modes/modo_enemys.tscn")
	$MenuContent/PanelModos/GridModos/TarjetaModoEnemigosVida/VBoxContainer/MejorPuntajeModo.text = \
		"Mejor: %d" % Estadisticas.mejor_puntaje_de("res://scenes/modes/modo_enemys_life.tscn")
	$MenuContent/PanelModos/GridModos/TarjetaModoSeguirEnemigo/VBoxContainer/MejorPuntajeModo.text = \
		"Mejor: %d" % Estadisticas.mejor_puntaje_de("res://scenes/modes/modo_follow_enemy.tscn")

# --- CONFIGURACIÓN ---

func _on_slider_sensibilidad_value_changed(value: float) -> void:
	GameSettings.mouse_sensitivity = value
	GameSettings.save_settings()
	$MenuContent/PanelConfiguracion/ValorSensibilidad.text = "%.3f" % value

func _on_check_pantalla_completa_toggled(toggled_on: bool) -> void:
	GameSettings.fullscreen = toggled_on
	GameSettings.save_settings()
	aplicar_pantalla_completa()

func _on_btn_salir_pressed() -> void:
	get_tree().quit()


func _on_btn_seleccionar_pressed() -> void:
	pass # Replace with function body.
