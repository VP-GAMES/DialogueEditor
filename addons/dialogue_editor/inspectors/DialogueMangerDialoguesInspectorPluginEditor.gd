# EditorProperty for Dialogue2D and Dialogue3D in DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends EditorProperty
class_name DialogueDialogueInspectorEditor

const Dropdown = preload("res://addons/dialogue_editor/ui_extensions/dropdown/Dropdown.tscn")

var updating = false
var dialogue_editor
var dropdown = Dropdown.instance()

func _init():
	add_child(dropdown)
	add_focusable(dropdown)
	dropdown.connect("gui_input", self, "_on_gui_input")
	dropdown.connect("selection_changed_value", self, "_on_selection_changed_value")

func _on_gui_input(event: InputEvent) -> void:
	dropdown.clear()
	if not dialogue_editor:
		dialogue_editor = get_tree().get_root().find_node("DialogueEditor", true, false)
	if dialogue_editor:
		var data = dialogue_editor.get_data() as DialogueData
		if data:
			for dialogue in data.dialogues:
				dropdown.add_item(dialogue.name)

func _on_selection_changed_value(value: String):
	if (updating):
		return
	emit_changed(get_edited_property(), value)

func update_property():
	var new_value = get_edited_object()[get_edited_property()]
	updating = true
	dropdown.text = new_value
	updating = false
