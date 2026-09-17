extends Panel

signal volver

func _ready() -> void:
	$SliderSensibilidad.value = GameSettings.mouse_sensitivity
	$CheckPantallaCompleta.button_pressed = GameSettings.fullscreen

func _on_btn_volver_pressed() -> void:
	volver.emit()

func _on_slider_sensibilidad_value_changed(value: float) -> void:
	GameSettings.mouse_sensitivity = value
	GameSettings.save_settings()

func _on_check_pantalla_completa_toggled(toggled_on: bool) -> void:
	GameSettings.fullscreen = toggled_on
	GameSettings.save_settings()

	if GameSettings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
