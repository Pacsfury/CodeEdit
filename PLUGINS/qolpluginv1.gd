extends Object

# AI-Generated Quality of Life Plugin: Recent Files & Bookmarks
# Basic QOL features
# Share your own plugins on PR!

var _fd_nodo: Node
var _historial: Array = []
var _favoritos: Array = []

var _popup_recientes: PopupMenu
var _popup_favoritos: PopupMenu

const SAVE_PATH_RECENT = "user://qol_recent_files.json"
const SAVE_PATH_FAVS   = "user://qol_favorite_paths.json"

func init():
	var main_tree = Engine.get_main_loop() as SceneTree
	if not main_tree or not main_tree.current_scene:
		return
		
	_fd_nodo = _encontrar_tu_file_dialog(main_tree.current_scene)
	if not is_instance_valid(_fd_nodo):
		return

	_cargar_datos()
	_inyectar_interfaz_qol()

	if _fd_nodo.file_selected.is_connected(_on_file_selected):
		_fd_nodo.file_selected.disconnect(_on_file_selected)
	_fd_nodo.file_selected.connect(_on_file_selected)

func _inyectar_interfaz_qol():
	# Buscamos el contenedor por su nombre único (%PluginContainer) en la escena actual
	var main_tree = Engine.get_main_loop() as SceneTree
	var container = main_tree.current_scene.find_child("PluginContainer", true, false)
	
	# Si no lo encuentra por nombre único, buscamos dentro del entorno del File Dialog
	if not container:
		container = _fd_nodo.find_child("PluginContainer", true, false)
	if not container: 
		return # Si no existe el contenedor, abortamos
	
	# Creamos los botones individuales
	var btn_recientes = Button.new()
	btn_recientes.text = "🕒 Recent"
	btn_recientes.flat = false
	
	var btn_favoritos = Button.new()
	btn_favoritos.text = "⭐ Favorites"
	btn_favoritos.flat = false

	container.add_child(btn_recientes)
	container.add_child(btn_favoritos)
	
	_popup_recientes = PopupMenu.new()
	_popup_favoritos = PopupMenu.new()
	_fd_nodo.add_child(_popup_recientes)
	_fd_nodo.add_child(_popup_favoritos)
	
	btn_recientes.pressed.connect(func():
		_actualizar_menu_recientes(_popup_recientes)
		_popup_recientes.popup(Rect2i(btn_recientes.global_position + Vector2(0, btn_recientes.size.y), Vector2i.ZERO))
	)
	
	btn_favoritos.pressed.connect(func():
		_actualizar_menu_favoritos(_popup_favoritos)
		_popup_favoritos.popup(Rect2i(btn_favoritos.global_position + Vector2(0, btn_favoritos.size.y), Vector2i.ZERO))
	)
	
	_popup_recientes.id_pressed.connect(_on_recent_selected)
	_popup_favoritos.id_pressed.connect(_on_fav_selected)

func _on_file_selected(path: String):
	if _historial.has(path):
		_historial.erase(path)
	_historial.insert(0, path)
	if _historial.size() > 10:
		_historial.pop_back()
	_guardar_datos()

func _on_recent_selected(id: int):
	if id < _historial.size():
		_fd_nodo.file_selected.emit(_historial[id])

func _on_fav_selected(id: int):
	if id == 999:
		var h_menu = _fd_nodo.h_menu
		if "actl_path" in h_menu and not h_menu.actl_path.is_empty():
			var carpeta_actual = h_menu.actl_path.get_base_dir()
			if not _favoritos.has(carpeta_actual):
				_favoritos.append(carpeta_actual)
				_guardar_datos()
		return
	if id == 998:
		_favoritos.clear()
		_guardar_datos()
		return
	if id < _favoritos.size():
		var path = _favoritos[id]
		var h_menu = _fd_nodo.h_menu
		if "actl_path" in h_menu:
			h_menu.actl_path = path
			_fd_nodo.file_selected.emit(path)

func _actualizar_menu_recientes(popup: PopupMenu):
	popup.clear()
	if _historial.is_empty():
		popup.add_item("No files here")
		popup.set_item_disabled(0, true)
		return
	for i in range(_historial.size()):
		popup.add_item(_historial[i].get_file(), i)
		popup.set_item_tooltip(i, _historial[i])

func _actualizar_menu_favoritos(popup: PopupMenu):
	popup.clear()
	popup.add_item("➕ Mark current folder", 999)
	popup.add_separator()
	if _favoritos.is_empty():
		popup.add_item("No favorites saved")
		popup.set_item_disabled(popup.get_item_count() - 1, true)
	else:
		for i in range(_favoritos.size()):
			popup.add_item(_favoritos[i].get_file() + " (Carpeta)", i)
			popup.set_item_tooltip(popup.get_item_index(i), _favoritos[i])
		popup.add_separator()
		popup.add_item("🗑️ Clear favorites", 998)

func _guardar_datos():
	var file = FileAccess.open(SAVE_PATH_RECENT, FileAccess.WRITE)
	if file: file.store_string(JSON.stringify(_historial))
	var file_fav = FileAccess.open(SAVE_PATH_FAVS, FileAccess.WRITE)
	if file_fav: file_fav.store_string(JSON.stringify(_favoritos))

func _cargar_datos():
	if FileAccess.file_exists(SAVE_PATH_RECENT):
		var file = FileAccess.open(SAVE_PATH_RECENT, FileAccess.READ)
		if file:
			var json_res = JSON.parse_string(file.get_as_text())
			if json_res is Array: _historial = json_res
	if FileAccess.file_exists(SAVE_PATH_FAVS):
		var file_fav = FileAccess.open(SAVE_PATH_FAVS, FileAccess.READ)
		if file_fav:
			var json_res = JSON.parse_string(file_fav.get_as_text())
			if json_res is Array: _favoritos = json_res

func _encontrar_tu_file_dialog(nodo: Node) -> Node:
	if "content" in nodo and "h_menu" in nodo and "plugins" in nodo:
		return nodo
	for hijo in nodo.get_children():
		var encontrado = _encontrar_tu_file_dialog(hijo)
		if encontrado: return encontrado
	return null
