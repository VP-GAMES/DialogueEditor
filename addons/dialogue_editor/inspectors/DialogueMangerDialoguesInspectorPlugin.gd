# EditorInspectorPlugin for Dialogue2D and Dialogue3D in DialogueEditor : MIT License
# @author Vladimir Petrenko
extends EditorInspectorPlugin

func can_handle(object):
	return object is Dialogue2D or object is Dialogue3D 

func parse_property(object, type, path, hint, hint_text, usage):
	if type == TYPE_STRING and path == "dialogue_name":
		add_property_editor(path, DialogueDialogueInspectorEditor.new())
		return true
	else:
		return false
