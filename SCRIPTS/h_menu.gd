extends Node

@onready var cont: HBoxContainer = $HBoxContainer
@onready var content: TextEdit = %Content

var actl_path = ""

func open(fname: String, fullpath: String) -> void:
	var newbtn: Button = Button.new()
	newbtn.text = fname
	cont.add_child(newbtn)
	
	newbtn.pressed.connect(func(): _clicked(fullpath))
	
	var newcbtn: Button = Button.new()
	newcbtn.text = 'X'
	newcbtn.pressed.connect(func(): _close(newbtn, newcbtn))
	cont.add_child(newcbtn)
	
	actl_path = fullpath
	
func _close(btn, cbtn):
	btn.queue_free()
	cbtn.queue_free()
	
func _clicked(path: String) -> void:
	content.text = FileAccess.get_file_as_string(path)
	actl_path = path
