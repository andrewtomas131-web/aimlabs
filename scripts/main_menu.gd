extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$MenuContent/PanelConfiguracion/SliderSensibilidad.value = GameSettings.mouse_sensitivity
	$MenuContent/PanelConfiguracion/CheckPantallaCompleta.button_pressed = GameSettings.fullscreen
	aplicar_pantalla_completa()
	
func aplicar_pantalla_completa() -> void:
	if GameSettings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_btn_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


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
