extends CharacterBody3D

signal target_hit

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.003
const SHOOT_DISTANCE = 10000.0

var anim_player: AnimationPlayer

@onready var head: Node3D = $Head
@onready var camera = $Head/Camera3D
@onready var shootRay = $Head/Camera3D/ShootRay


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	anim_player = find_child("AnimationPlayer", true, false)
	
	if anim_player:
		print(anim_player.get_animation_list())
	else:
		push_warning("No se encontró AnimationPlayer")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		head.rotate_x(event.relative.y * MOUSE_SENSITIVITY)
		head.rotation.x = clamp(
			head.rotation.x,
			deg_to_rad(-80),
			deg_to_rad(80)
		)

	if event.is_action_pressed("click"):
		anim_player.stop()
		anim_player.play("WEP_Fire")
		
		shoot()

	if event.is_action_pressed("inspeccionar"):
		anim_player.stop()
		anim_player.play("WEP_Inspect_01")


func shoot() -> void:
	print("Disparo")
	
	if not shootRay.is_colliding():
		print("NO SE DETECTÓ NADA")
		return
	
	var target = shootRay.get_collider()
	print("OBJETO DETECTADO")
	print("Nombre: ", target.name)
	print("Tipo: ", target.get_class())
	print("Posición: ", target.global_position)
	
	if target.is_in_group("target"):
		print("ES UNA BOLITA")
		target.hit()
	else:
		print("NO ES UNA BOLITA")



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
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector(
		"derecha",
		"izquierda",
		"atras",
		"adelante"
	)

	var direction := (
		transform.basis *
		Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		#aqui quite temporalmente la animacion de caminar
		#if (
			#anim_player
			#and anim_player.current_animation != "WEP_Fire"
			#and anim_player.current_animation != "WEP_Inspect_01"
		#):
			#anim_player.play("WEP_Walk")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
		if (
			anim_player
			and anim_player.current_animation != "WEP_Fire"
			and anim_player.current_animation != "WEP_Inspect_01"
		):
			anim_player.play("WEP_Idle")
	#comente el move and slide para que se quede fijo
	#move_and_slide()
