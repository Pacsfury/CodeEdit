extends FileDialog

@onready var content: TextEdit = %Content
@onready var h_menu: Node = %HMenu
@onready var plugins: Node = %PluginManager

func _ready() -> void:
	self.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	self.file_selected.connect(_on_file_selected)

func _on_open_pressed() -> void:
	self.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	if self.file_selected.is_connected(_on_file_selected):
		self.file_selected.disconnect(_on_file_selected)
	self.file_selected.connect(_on_file_selected)
	self.popup_centered()

func _on_file_selected(path: String) -> void:
	var text = FileAccess.get_file_as_string(path)
	content.text = text
	h_menu.open(path.get_file(), path)

func _on_save_file_pressed() -> void:
	var path = h_menu.actl_path
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(content.text)
		file.close()

func _on_save_as_pressed() -> void:
	self.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	
	if self.file_selected.is_connected(_on_file_selected):
		self.file_selected.disconnect(_on_file_selected)
		
	self.file_selected.connect(func(path): 
		FileAccess.open(path, FileAccess.WRITE).store_string(content.text)
		h_menu.open(path.get_file(), path)
	, CONNECT_ONE_SHOT)
	
	self.popup_centered()


func _on_add_file_as_plugin_pressed() -> void:
	self.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	self.popup_centered()
	
	var path: String = await self.file_selected
	
	if path.is_empty():
		return
		
	plugins.includePlugin(path)
