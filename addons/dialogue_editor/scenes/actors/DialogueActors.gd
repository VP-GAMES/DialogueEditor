# Dialogue actors UI for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends Panel

var _data: DialogueData

onready var _add_ui = $Margin/VBox/HBox/Add as Button
onready var _actors_ui = $Margin/VBox/Scroll/Actors

const DialogueActorUI = preload("res://addons/dialogue_editor/scenes/actors/DialogueActorUI.tscn")

func set_data(data: DialogueData) -> void:
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _add_ui.is_connected("pressed", self, "_on_add_pressed"):
		assert(_add_ui.connect("pressed", self, "_on_add_pressed") == OK)
	if not _data.is_connected("actor_added", self, "_on_actor_added"):
		assert(_data.connect("actor_added", self, "_on_actor_added") == OK)
	if not _data.is_connected("actor_removed", self, "_on_actor_removed"):
		assert(_data.connect("actor_removed", self, "_on_actor_removed") == OK)

func _on_add_pressed() -> void:
	_data.add_actor()

func _on_actor_added(actor: DialogueActor) -> void:
	_update_view()

func _on_actor_removed(actor: DialogueActor) -> void:
	_update_view()
	
func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	for actor_ui in _actors_ui.get_children():
		_actors_ui.remove_child(actor_ui)
		actor_ui.queue_free()

func _draw_view() -> void:
	for actor in _data.actors:
		_draw_actor(actor)

func _draw_actor(actor: DialogueActor) -> void:
	var actor_ui = DialogueActorUI.instance()
	_actors_ui.add_child(actor_ui)
	actor_ui.set_data(actor, _data)
