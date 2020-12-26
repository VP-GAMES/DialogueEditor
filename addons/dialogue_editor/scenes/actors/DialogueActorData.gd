# Dialogue actor data for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _data: DialogueData
var _actor: DialogueActor

onready var _add_ui = $MarginData/VBox/HBox/Add as Button
onready var _resources_ui = $MarginData/VBox/Resources as VBoxContainer
onready var _texture_ui = $MarginPreview/VBox/Texture as TextureRect

const DialogueActorDataResource = preload("res://addons/dialogue_editor/scenes/actors/DialogueActorDataResource.tscn")

func set_data(data: DialogueData):
	_data = data
	_texture_ui.set_data(data)
	_init_connections()
	_update_view()
	_draw_preview_default()

func _init_connections() -> void:
	if not _add_ui.is_connected("pressed", self, "_add_pressed"):
		_add_ui.connect("pressed", self, "_add_pressed")
	if not _data.is_connected("actor_selection_changed", self, "_on_actor_selection_changed"):
		_data.connect("actor_selection_changed", self, "_on_actor_selection_changed")
	if not _data.is_connected("actor_resource_added", self, "_on_actor_resource_added"):
		_data.connect("actor_resource_added", self, "_on_actor_resource_added")
	if not _data.is_connected("actor_resource_removed", self, "_on_actor_resource_removed"):
		_data.connect("actor_resource_removed", self, "_on_actor_resource_removed")

func _add_pressed() -> void:
	_data.add_actor_resource()
	_draw_preview_clear()

func _on_actor_selection_changed() -> void:
	_update_view()
	_draw_preview_default()

func _on_actor_resource_added(resource) -> void:
	_update_view()
	_resource_request_focus(resource)

func _on_actor_resource_removed(resource) -> void:
	_update_view()
	_draw_preview_default()

func _update_view() -> void:
	_actor = _data.selected_actor()
	if _actor:
		_clear_view()
		_draw_view()
	else:
		_clear_view()

func _draw_view() -> void:
	_add_ui.disabled = false
	for resource in _actor.resources:
		_draw_resource(resource)

func _clear_view() -> void:
	_add_ui.disabled = true
	for resource_ui in _resources_ui.get_children():
		_resources_ui.remove_child(resource_ui)
		resource_ui.queue_free()

func _draw_resource(resource) -> void:
	var resource_ui = DialogueActorDataResource.instance()
	_resources_ui.add_child(resource_ui)
	resource_ui.set_data(resource, _data)

func _resource_request_focus(resource) -> void:
	for resource_ui in _resources_ui.get_children():
		if resource_ui.resource() == resource:
			resource_ui.request_focus()

func _draw_preview_default() -> void:
	if _actor and not _actor.resources.empty():
		_texture_ui.set_resource(_actor.resources[0])
	else:
		_texture_ui.set_resource(null)

func _draw_preview_clear() -> void:
		_texture_ui.set_resource(null)
