extends Node

@onready var cont: HBoxContainer = $HBoxContainer
@onready var content: TextEdit = %Content

var actl_path = ""

func open(fname: String, fullpath: String) -> void:
	var newbtn: Button = Button.new()
	newbtn.text = fname
	cont.add_child(newbtn)
	
	newbtn.pressed.connect(func(): _clicked(fullpath))
	actl_path = fullpath
	
func _clicked(path: String) -> void:
	content.text = FileAccess.get_file_as_string(path)
	actl_path = path
