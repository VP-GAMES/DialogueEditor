# Dialogue actor data texture for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends TextureRect

var _resource
var _data: DialogueData

func set_data(data: DialogueData):
	_data = data
	_init_connections()

func _init_connections() -> void:
	if not _data.is_connected("actor_resource_path_changed", self, "_on_actor_resource_path_changed"):
		_data.connect("actor_resource_path_changed", self, "_on_actor_resource_path_changed")
	if not _data.is_connected("actor_resource_selection_changed", self, "_on_actor_resource_selection_changed"):
		_data.connect("actor_resource_selection_changed", self, "_on_actor_resource_selection_changed")

func _on_actor_resource_path_changed(resource) -> void:
	if _resource == resource:
		_update_view()

func _on_actor_resource_selection_changed(resource) -> void:
	set_resource(resource)

func set_resource(resource):
	_resource = resource
	_update_view()

func _update_view() -> void:
	var image = null
	if _resource and _data.resource_exists(_resource):
		image = load(_resource.path)
	texture = image
