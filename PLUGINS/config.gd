extends Object

# AI-Generated Quality of Life Plugin: Configuration
# Basic configuration
# Share your own plugins on PR!

var _fd_nodo: Node
var _config_panel: Window
var _txt_node: TextEdit

const SAVE_PATH_CONFIG = "user://qol_editor_config.json"

var _opciones = {
	"highlight_current_line": true,
	"word_wrap": false,
	"font_size": 14
}

func init():
	var main_tree = Engine.get_main_loop() as SceneTree
	if not main_tree or not main_tree.current_scene:
		return
		
	_fd_nodo = _encontrar_tu_file_dialog(main_tree.current_scene)
	if not is_instance_valid(_fd_nodo):
		return

	_txt_node = _fd_nodo.content
	if not is_instance_valid(_txt_node):
		return

	_cargar_configuracion()
	_aplicar_configuracion_al_editor()
	_inyectar_boton_configuracion()

func _inyectar_boton_configuracion():
	var main_tree = Engine.get_main_loop() as SceneTree
	var container = main_tree.current_scene.find_child("PluginContainer", true, false)
	
	if not container:
		container = _fd_nodo.find_child("PluginContainer", true, false)
	if not container: 
		return

	var btn_config = Button.new()
	btn_config.text = "⚙️ Configuration"
	btn_config.flat = false
	container.add_child(btn_config)
	
	btn_config.pressed.connect(_abrir_panel_configuracion)

func _abrir_panel_configuracion():
	if is_instance_valid(_config_panel):
		_config_panel.grab_focus()
		return
		
	_config_panel = Window.new()
	_config_panel.title = "Editor Configuration"
	_config_panel.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_MAIN_WINDOW_SCREEN
	_config_panel.size = Vector2i(320, 240)
	_config_panel.transient = true
	_config_panel.exclusive = false
	_config_panel.popup_window = true
	
	_config_panel.close_requested.connect(func(): _config_panel.queue_free())
	
	var margin_container = MarginContainer.new()
	margin_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", 15)
	margin_container.add_theme_constant_override("margin_top", 15)
	margin_container.add_theme_constant_override("margin_right", 15)
	margin_container.add_theme_constant_override("margin_bottom", 15)
	_config_panel.add_child(margin_container)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin_container.add_child(vbox)
	
	
	# 2. Checkbox: Resaltar línea actual
	var chk_highlight = CheckBox.new()
	chk_highlight.text = "Highlight Current Line"
	chk_highlight.button_pressed = _opciones["highlight_current_line"]
	chk_highlight.toggled.connect(func(button_pressed):
		_opciones["highlight_current_line"] = button_pressed
		_txt_node.highlight_current_line = button_pressed
		_guardar_configuracion()
	)
	vbox.add_child(chk_highlight)
	
	# 3. Checkbox: Ajuste de línea
	var chk_wrap = CheckBox.new()
	chk_wrap.text = "Automatic Line Adjustment"
	chk_wrap.button_pressed = _opciones["word_wrap"]
	chk_wrap.toggled.connect(func(button_pressed):
		_opciones["word_wrap"] = button_pressed
		_txt_node.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY if button_pressed else TextEdit.LINE_WRAPPING_NONE
		_guardar_configuracion()
	)
	vbox.add_child(chk_wrap)
	
	# 4. Control numérico: Tamaño de fuente
	var hbox_font = HBoxContainer.new()
	var lbl_font = Label.new()
	lbl_font.text = "Font Size:"
	lbl_font.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var spin_font = SpinBox.new()
	spin_font.min_value = 10
	spin_font.max_value = 32
	spin_font.value = _opciones["font_size"]
	spin_font.value_changed.connect(func(value):
		_opciones["font_size"] = int(value)
		_txt_node.add_theme_font_size_override("font_size", int(value))
		_guardar_configuracion()
	)
	
	hbox_font.add_child(lbl_font)
	hbox_font.add_child(spin_font)
	vbox.add_child(hbox_font)
	
	_fd_nodo.add_child(_config_panel)
	_config_panel.popup()

func _aplicar_configuracion_al_editor():
	if not is_instance_valid(_txt_node): return
	_txt_node.highlight_current_line = _opciones["highlight_current_line"]
	_txt_node.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY if _opciones["word_wrap"] else TextEdit.LINE_WRAPPING_NONE
	_txt_node.add_theme_font_size_override("font_size", _opciones["font_size"])

func _guardar_configuracion():
	var file = FileAccess.open(SAVE_PATH_CONFIG, FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(_opciones))

func _cargar_configuracion():
	if FileAccess.file_exists(SAVE_PATH_CONFIG):
		var file = FileAccess.open(SAVE_PATH_CONFIG, FileAccess.READ)
		if file:
			var json_res = JSON.parse_string(file.get_as_text())
			if json_res is Dictionary:
				for clave in json_res.keys():
					_opciones[clave] = json_res[clave]

func _encontrar_tu_file_dialog(nodo: Node) -> Node:
	if "content" in nodo and "h_menu" in nodo and "plugins" in nodo:
		return nodo
	for hijo in nodo.get_children():
		var encontrado = _encontrar_tu_file_dialog(hijo)
		if encontrado: return encontrado
	return null
