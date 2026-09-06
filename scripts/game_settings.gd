extends Node

var mouse_sensitivity: float = 0.003
var fullscreen: bool = false

const SETTINGS_PATH := "user://settings.cfg"


func _ready() -> void:
	load_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("mouse", "sensitivity", mouse_sensitivity)
	config.set_value("display", "fullscreen", fullscreen)
	config.save(SETTINGS_PATH)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		mouse_sensitivity = config.get_value(
			"mouse",
			"sensitivity",
			mouse_sensitivity
		)
		fullscreen = config.get_value(
			"display",
			"fullscreen",
			fullscreen
		)
