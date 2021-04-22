# EditorInspectorPlugin for Dialogue2D and Dialogue3D in DialogueEditor : MIT License
# @author Vladimir Petrenko
extends EditorInspectorPlugin

var _data: DialogueData

func set_data(data: DialogueData) -> void:
	_data = data

func can_handle(object):
	return object is Dialogue2D or object is Dialogue3D 

func parse_property(object, type, path, hint, hint_text, usage):
	if type == TYPE_STRING and path == "dialogue_name":
		var dialogueDialogueInspectorEditor = DialogueDialogueInspectorEditor.new()
		dialogueDialogueInspectorEditor.set_data(_data)
		add_property_editor(path, dialogueDialogueInspectorEditor)
		return true
	else:
		return false
