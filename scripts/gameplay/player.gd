extends CharacterBody3D

@export var speed:float = 7.0
@export var jump_velocity:float = 5.0
@export var aceleracion: float = 25.0
@export var friccion: float = 25.0

var anim_player: AnimationPlayer

@onready var current_weapon: Weapon = $Head
@onready var head: Node3D = $Head
@onready var camera:Camera3D = $Head/Camera3D

# Crosshair
@onready var crosshair:CenterContainer = $UI/Crosshair
@onready var crosshair_hit:CenterContainer = $UI/Crosshair_hit

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	anim_player = find_child("AnimationPlayer", true, false)
	
	if not anim_player:
		push_warning("No se encontró AnimationPlayer")
		
	current_weapon.hit_target.connect(crosshair_hit_effect)
	if current_weapon.has_signal("recoil_kick"):
		current_weapon.recoil_kick.connect(_on_recoil_kick)
# Configuración del crosshair
	crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crosshair_hit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	crosshair.visible = true
	crosshair_hit.visible = false
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * GameSettings.mouse_sensitivity)
		
		head.rotate_x(event.relative.y * GameSettings.mouse_sensitivity)
		head.rotation.x = clamp(
			head.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)
		
	if event.is_action_pressed("click"):
		current_weapon.fire()
		
	if event.is_action_released("click"):
		current_weapon.stop_fire()
		if current_weapon.has_method("reset_burst"):
			current_weapon.reset_burst()

	if event.is_action_pressed("inspeccionar"):
		current_weapon.inspect()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED
		)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector(
		"derecha",
		"izquierda",
		"atras",
		"adelante"
	)
	if input_dir and not current_weapon.wants_to_fire: 
		current_weapon.play_walk()
	else:
		current_weapon.play_idle()
	var direction := (
		transform.basis *
		Vector3(input_dir.x, 0, input_dir.y)
	).normalized()
	var objetivo := direction * speed
	var ritmo := aceleracion if direction.length() > 0.1 else friccion
	
	velocity.x = move_toward(velocity.x, objetivo.x, ritmo * delta)
	velocity.z = move_toward(velocity.z, objetivo.z, ritmo * delta)
	
	
	move_and_slide()

func crosshair_hit_effect() -> void:
	crosshair.visible = false
	crosshair_hit.visible = true

	await get_tree().create_timer(0.1).timeout

	crosshair.visible = true
	crosshair_hit.visible = false
	
func _on_recoil_kick(offset: Vector2) -> void:
	rotate_y(-deg_to_rad(offset.x) * 0.1)
	head.rotate_x(-deg_to_rad(offset.y) * 0.1)
	head.rotation.x = clamp(head.rotation.x, deg_to_rad(-80), deg_to_rad(80))
