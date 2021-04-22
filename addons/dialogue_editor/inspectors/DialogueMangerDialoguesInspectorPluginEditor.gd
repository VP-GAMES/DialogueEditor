# EditorProperty for Dialogue2D and Dialogue3D in DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends EditorProperty
class_name DialogueDialogueInspectorEditor

const Dropdown = preload("res://addons/dialogue_editor/ui_extensions/dropdown_uuid/Dropdown.tscn")

var updating = false
var dialogue_editor
var dropdown = Dropdown.instance()
var _data: DialogueData
var _items: Array

func set_data(data: DialogueData) -> void:
	_data = data
	_items = _data.dialogues

func _init():
	add_child(dropdown)
	add_focusable(dropdown)
	dropdown.connect("gui_input", self, "_on_gui_input")
	dropdown.connect("selection_changed", self, "_on_selection_changed")

func _on_gui_input(event: InputEvent) -> void:
	_items = _data.dialogues
	dropdown.clear()
	for item in _items:
		var item_d = {"text": item.name, "value": item.uuid }
		dropdown.add_item(item_d)

func _on_selection_changed(item: Dictionary):
	if (updating):
		return
	emit_changed(get_edited_property(), item.value)

func update_property():
	var new_value = get_edited_object()[get_edited_property()]
	updating = true
	var item = item_by_uuid(new_value)
	if item and item.text:
		dropdown.text = item.text
	updating = false

func item_by_uuid(uuid: String) -> Dictionary:
	for item in _items:
		if item.uuid == uuid:
			return {"text": item.name, "value": item.uuid}
	return {"text": null, "value": null}
