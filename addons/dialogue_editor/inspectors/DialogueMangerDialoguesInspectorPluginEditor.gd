# EditorProperty for Dialogue2D and Dialogue3D in DialogueEditor : MIT License
# @author Vladimir Petrenko
extends EditorProperty
class_name DialogueDialogueInspectorEditor

const Dropdown = preload("res://addons/dialogue_editor/ui_extensions/dropdown/Dropdown.tscn")

var updating = false
var dropdown = Dropdown.instance()

func _init():
	add_child(dropdown)
	add_focusable(dropdown)
	dropdown.connect("gui_input", self, "_on_gui_input")
	dropdown.connect("selection_changed_value", self, "_on_selection_changed_value")

func _on_gui_input(event: InputEvent) -> void:
	dropdown.clear()
	for item in DialogueMangerDialogues.DIALOGUES:
		dropdown.add_item(item)

func _on_selection_changed_value(value: String):
	if (updating):
		return
	emit_changed(get_edited_property(), value)

func update_property():
	var new_value = get_edited_object()[get_edited_property()]
	updating = true
	dropdown.text = new_value
	updating = false
