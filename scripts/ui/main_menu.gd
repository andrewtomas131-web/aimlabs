extends Control

@onready var mejor_puntaje_label: Label = $MenuContent/MejorPuntaje


func _ready() -> void:
	$MenuContent/PanelConfiguracion/SliderSensibilidad.value = GameSettings.mouse_sensitivity
	$MenuContent/PanelConfiguracion/CheckPantallaCompleta.button_pressed = GameSettings.fullscreen
	aplicar_pantalla_completa()
	_actualizar_mejor_puntaje()

	
func aplicar_pantalla_completa() -> void:
	if GameSettings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _actualizar_mejor_puntaje() -> void:
	if mejor_puntaje_label:
		mejor_puntaje_label.text = "MEJOR PUNTAJE: %d" % Estadisticas.mejor_puntuacion


# --- NAVEGACIÓN Y MENÚS ---

func _on_btn_jugar_pressed() -> void:
	$MenuContent/PanelModos.visible = true


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
	Estadisticas.reset()
	get_tree().change_scene_to_file("res://scenes/modes/main.tscn")


func _on_btn_modo_enemigos_pressed() -> void:
	Estadisticas.reset()
	get_tree().change_scene_to_file("res://scenes/modes/modo_enemys.tscn")


func _on_btn_modo_3_pressed() -> void:
	Estadisticas.reset()
	get_tree().change_scene_to_file("res://scenes/modes/modo_enemys_life.tscn")


func _on_btn_modo_4_pressed() -> void:
	Estadisticas.reset()
	get_tree().change_scene_to_file("res://scenes/modes/modo_follow_enemy.tscn")


# --- CONFIGURACIÓN ---

func _on_slider_sensibilidad_value_changed(value: float) -> void:
	GameSettings.mouse_sensitivity = value
	GameSettings.save_settings()


func _on_check_pantalla_completa_toggled(toggled_on: bool) -> void:
	GameSettings.fullscreen = toggled_on
	GameSettings.save_settings()
	aplicar_pantalla_completa()
