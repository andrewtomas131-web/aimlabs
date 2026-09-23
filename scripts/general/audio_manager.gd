extends Node

const RUTA_AUDIO := "res://assets/audio/"
const VOCES := 20

var _variaciones: Dictionary = {}
var _ultima_variacion: Dictionary = {}
var _voces: Array[AudioStreamPlayer] = []
var _siguiente_voz: int = 0
var _loops: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_cargar_sonidos()

	for i in VOCES:
		var p := AudioStreamPlayer.new()
		p.bus = &"Master"
		p.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(p)
		_voces.append(p)

	get_tree().node_added.connect(_on_node_added)
	_conectar_existentes.call_deferred()

func _cargar_sonidos() -> void:
	var dir := DirAccess.open(RUTA_AUDIO)

	if dir == null:
		push_warning("AudioManager: no existe la carpeta " + RUTA_AUDIO)
		return

	dir.list_dir_begin()
	var archivo := dir.get_next()

	while archivo != "":
		if not dir.current_is_dir() and archivo.to_lower().ends_with(".wav"):
			var nombre: String = archivo.substr(0, archivo.length() - 4)
			var base := nombre

			var partes := nombre.rsplit("_", true, 1)
			if partes.size() == 2 and partes[1].is_valid_int():
				base = partes[0]

			var ruta := RUTA_AUDIO + archivo
			var stream: AudioStream = load(ruta)

			if stream != null:
				if not _variaciones.has(base):
					_variaciones[base] = []

				_variaciones[base].append(stream)

		archivo = dir.get_next()

	dir.list_dir_end()

func _normalizar_nombre(nombre: String) -> String:
	if nombre.to_lower().ends_with(".wav"):
		return nombre.substr(0, nombre.length() - 4)

	return nombre

func play(nombre_base: String, volumen_db: float = 0.0, variacion_tono: float = 0.0) -> void:
	nombre_base = _normalizar_nombre(nombre_base)

	var stream := _elegir_variacion(nombre_base)
	if stream == null:
		return

	var voz := _voz_libre()
	voz.stream = stream
	voz.volume_db = volumen_db
	voz.pitch_scale = 1.0 + randf_range(-variacion_tono, variacion_tono)
	voz.play()

func _elegir_variacion(nombre_base: String) -> AudioStream:
	nombre_base = _normalizar_nombre(nombre_base)

	var lista: Array = _variaciones.get(nombre_base, [])

	if lista.is_empty():
		push_warning("AudioManager: falta el sonido '%s.wav' en %s" % [nombre_base, RUTA_AUDIO])
		return null

	if lista.size() == 1:
		return lista[0]

	var idx := randi_range(0, lista.size() - 1)

	if idx == _ultima_variacion.get(nombre_base, -1):
		idx = (idx + 1) % lista.size()

	_ultima_variacion[nombre_base] = idx
	return lista[idx]

func _voz_libre() -> AudioStreamPlayer:
	for v in _voces:
		if not v.playing:
			return v

	var v := _voces[_siguiente_voz]
	_siguiente_voz = (_siguiente_voz + 1) % _voces.size()
	return v

func play_loop(nombre: String, volumen_db: float = 0.0) -> void:
	nombre = _normalizar_nombre(nombre)

	var voz: AudioStreamPlayer = _loops.get(nombre)

	if voz == null:
		var lista: Array = _variaciones.get(nombre, [])

		if lista.is_empty():
			push_warning("AudioManager: falta el sonido en bucle '%s.wav'" % nombre)
			return

		voz = AudioStreamPlayer.new()
		voz.process_mode = Node.PROCESS_MODE_ALWAYS
		voz.bus = &"Master"

		var stream: AudioStream = lista[0]

		if stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			stream.loop_begin = 0
			stream.loop_end = stream.data.size() / (2 if stream.format == AudioStreamWAV.FORMAT_16_BITS else 1)

		voz.stream = stream
		add_child(voz)
		_loops[nombre] = voz

	voz.volume_db = volumen_db

	if not voz.playing:
		voz.play()

func stop_loop(nombre: String, fundido: float = 0.15) -> void:
	nombre = _normalizar_nombre(nombre)

	var voz: AudioStreamPlayer = _loops.get(nombre)

	if voz == null or not voz.playing:
		return

	if fundido <= 0.0:
		voz.stop()
		return

	var t := create_tween()
	t.tween_property(voz, "volume_db", -40.0, fundido)
	t.tween_callback(voz.stop)
	t.tween_callback(func(): voz.volume_db = 0.0)

func _conectar_existentes() -> void:
	var pendientes: Array[Node] = [get_tree().root]

	while not pendientes.is_empty():
		var nodo: Node = pendientes.pop_back()
		pendientes.append_array(nodo.get_children())
		_on_node_added(nodo)

func _on_node_added(nodo: Node) -> void:
	if nodo is BaseButton and not nodo.has_meta("audio_ui_conectado"):
		nodo.set_meta("audio_ui_conectado", true)

		var boton := nodo as BaseButton

		boton.mouse_entered.connect(func():
			if not boton.disabled:
				play("ui_hover", -6.0))

		boton.pressed.connect(func(): play("ui_click"))
