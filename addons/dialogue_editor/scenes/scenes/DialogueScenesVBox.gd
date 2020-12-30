# Dialogues container to drag and drop scene data for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends VBoxContainer

var _data: DialogueData

func set_data(data: DialogueData) -> void:
	_data = data

func can_drop_data(position, data) -> bool:
	var resource_value = data["files"][0]
	return _data.file_extension(resource_value) == "tscn"

func drop_data(position, data) -> void:
	var resource_value = data["files"][0]
	_data.add_scene(resource_value)
