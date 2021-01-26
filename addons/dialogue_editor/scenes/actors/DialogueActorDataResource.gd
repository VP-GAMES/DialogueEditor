# Dialogue actor data resource for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _resource: Dictionary
var _actor: DialogueActor
var _data: DialogueData

onready var _name_ui = $Name as LineEdit
onready var _put_ui = $Put as TextureRect
onready var _path_ui = $Path as LineEdit
onready var _del_ui = $Del as Button

func resource():
	return _resource

func set_data(resource: Dictionary, actor: DialogueActor, data: DialogueData):
	_resource = resource
	_actor = actor
	_data = data
	_put_ui.set_data(_resource, _actor, _data)
	_path_ui.set_data(_resource, _actor, _data)
	_init_connections()
	_update_view()

func request_focus() -> void:
	_name_ui.grab_focus()

func _init_connections() -> void:
	if not _actor.is_connected("resource_name_changed", self, "_on_resource_name_changed"):
		assert(_actor.connect("resource_name_changed", self, "_on_resource_name_changed") == OK)
	if not _name_ui.is_connected("gui_input", self, "_on_name_gui_input"):
		assert(_name_ui.connect("gui_input", self, "_on_name_gui_input") == OK)
	if not _name_ui.is_connected("text_changed", self, "_on_name_changed"):
		assert(_name_ui.connect("text_changed", self, "_on_name_changed") == OK)
	if not _del_ui.is_connected("pressed", self, "_del_pressed"):
		assert(_del_ui.connect("pressed", self, "_del_pressed") == OK)

func _on_resource_name_changed(resource) -> void:
	if _resource == resource:
		_update_view()

func _on_name_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			_actor.select_resource(_resource)

func _on_name_changed(new_text: String) -> void:
	_actor.change_resource_name(_resource, new_text)

func _del_pressed() -> void:
	_actor.del_resource(_resource)

func _update_view() -> void:
	_name_ui.text = _resource.name
