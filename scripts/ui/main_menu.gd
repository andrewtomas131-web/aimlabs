extends Control


func _ready() -> void:
	$MenuContent/PanelConfiguracion/SliderSensibilidad.value = GameSettings.mouse_sensitivity
	$MenuContent/PanelConfiguracion/CheckPantallaCompleta.button_pressed = GameSettings.fullscreen
	aplicar_pantalla_completa()
	
func aplicar_pantalla_completa() -> void:
	if GameSettings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_btn_jugar_pressed() -> void:
	$MenuContent/PanelModos.visible = true


func _on_btn_modo_normal_pressed() -> void:
	Estadisticas.reset()
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_btn_modo_enemigos_pressed() -> void:
	Estadisticas.reset()
	get_tree().change_scene_to_file("res://scenes/modo_enemys.tscn")


func _on_btn_modo_3_pressed() -> void:
	# Todavía no existe una escena para este modo.
	# Cuando la crees, conéctala aquí, por ejemplo:
	# Estadisticas.reset()
	# get_tree().change_scene_to_file("res://scenes/modo_3.tscn")
	pass


func _on_btn_volver_modos_pressed() -> void:
	$MenuContent/PanelModos.visible = false


func _on_btn_configuracion_pressed() -> void:
	$MenuContent/PanelConfiguracion.visible = true


func _on_btn_volver_pressed() -> void:
	$MenuContent/PanelConfiguracion.visible = false


func _on_slider_sensibilidad_value_changed(value: float) -> void:
	GameSettings.mouse_sensitivity = value
	GameSettings.save_settings()


func _on_check_pantalla_completa_toggled(toggled_on: bool) -> void:
	GameSettings.fullscreen = toggled_on
	GameSettings.save_settings()
	aplicar_pantalla_completa()
	
	
func _on_btn_ayuda_pressed() -> void:
	$PanelAyuda.visible = true


func _on_btn_entendido_pressed() -> void:
	$PanelAyuda.visible = false
