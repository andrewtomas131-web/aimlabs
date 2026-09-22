extends Node

var mouse_sensitivity: float = 0.003
var fullscreen: bool = false
var fov: float = 75.0

var selected_weapon_scene: PackedScene

const SETTINGS_PATH := "user://settings.cfg"
const PLAYER_PISTOL = preload("res://scenes/player_pistol.tscn")
const PLAYER_AK = preload("res://scenes/player_ak47.tscn")

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("mouse", "sensitivity", mouse_sensitivity)
	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("camera", "fov", fov)
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
		fov = config.get_value(
			"camera",
			"fov", 
			fov)
