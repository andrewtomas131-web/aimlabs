extends CanvasLayer

@onready var panel = $Panel
@onready var panel_configuracion = $Panel/PanelConfiguracion

func _ready() -> void:
	panel.hide()
	panel_configuracion.hide()
	panel_configuracion.volver.connect(_on_configuracion_volver)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause() -> void:
	if get_tree().paused:
		resume_game()
	else:
		pause_game()

func pause_game() -> void:
	panel.show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func resume_game() -> void:
	panel.hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_continue_button_pressed() -> void:
	resume_game()

func _on_settings_button_pressed() -> void:
	$Panel/VBoxContainer.hide()
	$Panel/PanelConfiguracion.show()

func _on_configuracion_volver() -> void:
	$Panel/PanelConfiguracion.hide()
	$Panel/VBoxContainer.show()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
