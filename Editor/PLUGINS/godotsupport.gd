extends Object

# AI-Generated plugin.
# This plugin provides basic highlighting on .gd files
# Share your own plugins on PR!

func init():
	
	var stack = get_stack()
	var llamador: Object = null
	
	for frame in stack:
		if frame.has("source") and "plugins.includePlugin" in frame.get("function", ""):
			pass
			
	var main_tree = Engine.get_main_loop() as SceneTree
	var fd = _encontrar_tu_file_dialog(main_tree.current_scene)
	
	if not is_instance_valid(fd):
		return

	var txt: TextEdit = fd.content
	var h_menu: Node = fd.h_menu

	var highlighter = CodeHighlighter.new()
	var c_keyword   = Color("#ff7085")
	var c_type      = Color("#42ffc2")
	var c_builtin   = Color("#42b3ff")
	var c_string    = Color("#ffd35c")
	var c_comment   = Color("#7c8f9e")
	
	var keywords = ["extends", "classname", "class", "func", "var", "const", "if", "else", "return", "pass", "self"]
	for kw in keywords: highlighter.add_keyword_color(kw, c_keyword)
	var types = ["int", "float", "bool", "String", "Array", "Dictionary", "Vector2"]
	for t in types: highlighter.add_keyword_color(t, c_type)
	
	highlighter.add_color_region('"', '"', c_string, false)
	highlighter.add_color_region("'", "'", c_string, false)
	highlighter.add_color_region("#", "", c_comment, true)
	highlighter.number_color = Color("#a1ecff")
	highlighter.symbol_color = Color("#abc7f5")

	fd.file_selected.connect(func(path: String):
		
		if path.get_extension().to_lower() == "gd":
			txt.add_theme_color_override("background_color", Color("#1a1c23"))
			txt.add_theme_color_override("font_color", Color("#e0e4ec"))
			txt.add_theme_color_override("font_selected_color", Color("#ffffff"))
			txt.add_theme_color_override("selection_color", Color("#2b3e57"))
			txt.add_theme_color_override("caret_color", Color("#ffffff"))
			
			txt.syntax_highlighter = highlighter
		else:
			txt.syntax_highlighter = null
			txt.remove_theme_color_override("background_color")
			txt.remove_theme_color_override("font_color")
			txt.remove_theme_color_override("font_selected_color")
			txt.remove_theme_color_override("selection_color")
			txt.remove_theme_color_override("caret_color")
	)
	
	if "actl_path" in h_menu and not h_menu.actl_path.is_empty():
		fd.file_selected.emit(h_menu.actl_path)

func _encontrar_tu_file_dialog(nodo: Node) -> Node:
	if "content" in nodo and "h_menu" in nodo and "plugins" in nodo:
		return nodo
	for hijo in nodo.get_children():
		var encontrado = _encontrar_tu_file_dialog(hijo)
		if encontrado: return encontrado
	return null
