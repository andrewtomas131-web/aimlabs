extends Panel

signal volver

func _ready() -> void:
	$SliderSensibilidad.value = GameSettings.mouse_sensitivity
	$CheckPantallaCompleta.button_pressed = GameSettings.fullscreen
	$SliderFOV.value = GameSettings.fov
	_actualizar_valor_sensibilidad(GameSettings.mouse_sensitivity)
	_actualizar_valor_fov(GameSettings.fov)

func _on_btn_volver_pressed() -> void:
	volver.emit()

func _on_slider_sensibilidad_value_changed(value: float) -> void:
	GameSettings.mouse_sensitivity = value
	GameSettings.save_settings()
	_actualizar_valor_sensibilidad(value)

func _actualizar_valor_sensibilidad(value: float) -> void:
	$ValorSensibilidad.text = "%.3f" % value

func _on_check_pantalla_completa_toggled(toggled_on: bool) -> void:
	GameSettings.fullscreen = toggled_on
	GameSettings.save_settings()

	if GameSettings.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_slider_fov_value_changed(value: float) -> void:
	GameSettings.fov = value
	GameSettings.save_settings()
	_actualizar_valor_fov(value)

	var camara := get_viewport().get_camera_3d()
	if camara:
		camara.fov = value

func _actualizar_valor_fov(value: float) -> void:
	$ValorFOV.text = "%d°" % int(value)
