# Dialogues dialogs list view for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends Panel

var _data: DialogueData

onready var _add_ui = $Margin/VBox/HBox/Add as Button
onready var _dialogues_ui = $Margin/VBox/Scroll/Dialogues
onready var _nodes_ui = $Margin/VBox/HBox/Nodes as Button
onready var _bricks_ui = $Margin/VBox/HBox/Bricks as Button

const DialogueDialogueUI = preload("res://addons/dialogue_editor/scenes/dialogues/DialogueDialogueUI.tscn")

func set_data(data: DialogueData) -> void:
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _add_ui.is_connected("pressed", self, "_add_pressed"):
		_add_ui.connect("pressed", self, "_add_pressed")
	if not _data.is_connected("dialogue_added", self, "_on_dialogue_action"):
		_data.connect("dialogue_added", self, "_on_dialogue_action")
	if not _data.is_connected("dialogue_removed", self, "_on_dialogue_action"):
		_data.connect("dialogue_removed", self, "_on_dialogue_action")

func _on_dialogue_action(dialogue: DialogueDialogue) -> void:
	_update_view()

func _update_view() -> void:
	_clear_view()
	_draw_view()

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

func _add_pressed() -> void:
	_data.add_dialogue()
