extends Node

@onready var txt: TextEdit = %Content
@onready var fd: FileDialog = $"../FileDialog"

func includePlugin(path: String):
	var ns = GDScript.new()
	
	ns.source_code = FileAccess.get_file_as_string(path)
	
	var error = ns.reload()
	if error != OK:
		print("Error compiling GDScript: ", error)
		return

	var obj = Object.new()
	obj.set_script(ns)
	
	if obj.has_method("init"):
		obj.call("init")
		
		if obj.has_meta("highlighter"):
			var highlighter = obj.get_meta("highlighter")
			txt.syntax_highlighter = highlighter
	
