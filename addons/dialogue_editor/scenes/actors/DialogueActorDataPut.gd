# Drag and drop UI for DialogueEditor : MIT License
# @author Vladimir Petrenko
# This is a workaround for https://github.com/godotengine/godot/issues/30480
tool
extends TextureRect

var _resource: Dictionary
var _actor: DialogueActor
var _data: DialogueData

func set_data(resource: Dictionary, actor: DialogueActor, data: DialogueData) -> void:
	_resource = resource
	_actor = actor
	_data = data

func can_drop_data(position, data) -> bool:
	var resource_value = data["files"][0]
	var resource_extension = _data.file_extension(resource_value)
	for extension in _data.SUPPORTED_ACTOR_RESOURCES:
		if resource_extension == extension:
			return true
	return false

func drop_data(position, data) -> void:
	var resource_value = data["files"][0]
	_resource_value_changed(resource_value)

func _resource_value_changed(resource_value) -> void:
	_actor.change_resource_path(_resource, resource_value)
