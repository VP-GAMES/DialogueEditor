# Dialogue actor data resource for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _resource: Dictionary
var _data: DialogueData

onready var _name_ui = $Name as LineEdit
onready var _put_ui = $Put as TextureRect
onready var _path_ui = $Path as LineEdit
onready var _del_ui = $Del as Button

func resource():
	return _resource

func set_data(resource: Dictionary, data: DialogueData):
	_resource = resource
	_data = data
	_put_ui.set_data(resource, data)
	_path_ui.set_data(resource, data)
	_init_connections()
	_update_view()

func request_focus() -> void:
	_name_ui.grab_focus()

func _init_connections() -> void:
	if not _name_ui.is_connected("gui_input", self, "_on_name_gui_input"):
		_name_ui.connect("gui_input", self, "_on_name_gui_input")
	if not _name_ui.is_connected("text_changed", self, "_on_name_changed"):
		_name_ui.connect("text_changed", self, "_on_name_changed")
	if not _del_ui.is_connected("pressed", self, "_del_pressed"):
		_del_ui.connect("pressed", self, "_del_pressed")

func _on_name_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			_data.actor_resource_selection(_resource)

func _on_name_changed(new_text: String) -> void:
	_data.actor_resource_name_change(_resource, new_text)

func _del_pressed() -> void:
	_data.del_actor_resource(_resource)

func _update_view() -> void:
	_name_ui.text = _resource.name
