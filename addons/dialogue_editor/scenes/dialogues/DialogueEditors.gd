# Dialogues editors view for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _data: DialogueData
var _dialogue: DialogueDialogue

const DialogueNodesView = preload("res://addons/dialogue_editor/scenes/dialogues/nodes_view/DialogueNodesView.tscn")
const DialogueBricksView = preload("res://addons/dialogue_editor/scenes/dialogues/bricks_view/DialogueBricksView.tscn")

func set_data(data: DialogueData) -> void:
	_data = data
	_dialogue = _data.selected_dialogue()
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _data.is_connected("dialogue_view_selection_changed", self, "_on_dialogue_view_selection_changed"):
		assert(_data.connect("dialogue_view_selection_changed", self, "_on_dialogue_view_selection_changed") == OK)
	if not _data.is_connected("dialogue_selection_changed", self, "_on_dialogue_selection_changed"):
		assert(_data.connect("dialogue_selection_changed", self, "_on_dialogue_selection_changed") == OK)

func _on_dialogue_view_selection_changed() -> void:
	_update_view()

func _on_dialogue_selection_changed(dialogue: DialogueDialogue) -> void:
	_dialogue = dialogue
	_update_view()

func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	for child_ui in get_children():
		remove_child(child_ui)
		child_ui.queue_free()

func _draw_view() -> void:
	var type = _data.setting_dialogues_editor_type()
	match type:
		"NODES":
			_draw_nodes_view()
		"BRICKS":
			_draw_bricks_view()

func _draw_nodes_view() -> void:
	var nodes_ui = DialogueNodesView.instance()
	add_child(nodes_ui)
	nodes_ui.set_data(_dialogue, _data)

func _draw_bricks_view() -> void:
	var bricks_ui = DialogueBricksView.instance()
	add_child(bricks_ui)
	#bricks_ui.set_data(_data)
