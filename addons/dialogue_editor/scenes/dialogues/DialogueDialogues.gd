# Dialogues dialogs list view for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends Panel

var _data: DialogueData

onready var _add_ui = $Margin/VBox/HBox/Add as Button
onready var _dialogues_ui = $Margin/VBox/Scroll/Dialogues
onready var _play_ui = $Margin/VBox/HBox/Play as Button
onready var _nodes_ui = $Margin/VBox/HBox/Nodes as Button
onready var _bricks_ui = $Margin/VBox/HBox/Bricks as Button

const DialogueDialogueUI = preload("res://addons/dialogue_editor/scenes/dialogues/DialogueDialogueUI.tscn")
const DialogueDialoguesPlayer = preload("res://addons/dialogue_editor/scenes/dialogues/DialogueDialoguesPlayer.tscn")

func set_data(data: DialogueData) -> void:
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _add_ui.is_connected("pressed", self, "_add_pressed"):
		assert(_add_ui.connect("pressed", self, "_add_pressed") == OK)
	if not _data.is_connected("dialogue_added", self, "_on_dialogue_action"):
		assert(_data.connect("dialogue_added", self, "_on_dialogue_action") == OK)
	if not _data.is_connected("dialogue_removed", self, "_on_dialogue_action"):
		assert(_data.connect("dialogue_removed", self, "_on_dialogue_action") == OK)
	if not _play_ui.is_connected("pressed", self, "_on_play_pressed"):
		assert(_play_ui.connect("pressed", self, "_on_play_pressed") == OK)
	if not _nodes_ui.is_connected("pressed", self, "_on_type_pressed"):
		assert(_nodes_ui.connect("pressed", self, "_on_type_pressed", ["NODES"]) == OK)
	if not _bricks_ui.is_connected("pressed", self, "_on_type_pressed"):
		assert(_bricks_ui.connect("pressed", self, "_on_type_pressed", ["BRICKS"]) == OK)

func _add_pressed() -> void:
	_data.add_dialogue()

func _on_dialogue_action(dialogue: DialogueDialogue) -> void:
	_update_view()

func _on_play_pressed() -> void:
	_data.editor().get_editor_interface().play_custom_scene(DialogueDialoguesPlayer.get_path())

func _update_view() -> void:
	_draw_editor_type()
	_clear_view()
	_draw_view()

func _on_type_pressed(type: String) -> void:
	_data.setting_dialogues_editor_type_put(type)
	_draw_editor_type()

func _draw_editor_type() -> void:
	_nodes_ui.set_pressed(false)
	_bricks_ui.set_pressed(false)
	var type = _data.setting_dialogues_editor_type()
	match type:
		"NODES":
			_nodes_ui.set_pressed(true)
		"BRICKS":
			_bricks_ui.set_pressed(true)

func _clear_view() -> void:
	for dialogue_ui in _dialogues_ui.get_children():
		_dialogues_ui.remove_child(dialogue_ui)
		dialogue_ui.queue_free()

func _draw_view() -> void:
	for dialogue in _data.dialogues:
		_draw_dialogue(dialogue)

func _draw_dialogue(dialogue: DialogueDialogue) -> void:
	var dialogue_ui = DialogueDialogueUI.instance()
	_dialogues_ui.add_child(dialogue_ui)
	dialogue_ui.set_data(dialogue, _data)
