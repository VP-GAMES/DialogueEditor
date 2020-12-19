# Dialogue actor data for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _data: DialogueData
var _actor: DialogueActor

onready var _add_ui = $MarginData/VBox/HBox/Add as Button
onready var _resources_ui = $MarginData/VBox/Resources as VBoxContainer

const DialogueActorDataResource = preload("res://addons/dialogue_editor/scenes/actors/DialogueActorDataResource.tscn")

func set_data(data: DialogueData):
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _add_ui.is_connected("pressed", self, "_add_pressed"):
		_add_ui.connect("pressed", self, "_add_pressed")
	if not _data.is_connected("actor_selection_changed", self, "_on_actor_selection_changed"):
		_data.connect("actor_selection_changed", self, "_on_actor_selection_changed")
	if not _data.is_connected("actor_resource_added", self, "_on_actor_resource_action"):
		_data.connect("actor_resource_added", self, "_on_actor_resource_action")
	if not _data.is_connected("actor_resource_removed", self, "_on_actor_resource_action"):
		_data.connect("actor_resource_removed", self, "_on_actor_resource_action")

func _add_pressed() -> void:
	_data.add_actor_resource()

func _on_actor_selection_changed() -> void:
	_update_view()

func _on_actor_resource_action(resource) -> void:
	_update_view()

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
