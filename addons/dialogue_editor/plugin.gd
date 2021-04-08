# Plugin DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends EditorPlugin

const IconResource = preload("res://addons/dialogue_editor/icons/Dialogue.png")
const DialogueMain = preload("res://addons/dialogue_editor/DialogueEditor.tscn")

# New Types
const DialogueDialogue2D = preload("res://addons/dialogue_editor/DialogueDialogue2D.gd")
const DialogueDialogue3D = preload("res://addons/dialogue_editor/DialogueDialogue3D.gd")
const DialogueIcon = preload("res://addons/dialogue_editor/icons/Dialogue.png")

var _dialogue_main
var _dialogue_editor_plugin

func _enter_tree():
	_dialogue_main = DialogueMain.instance()
	_dialogue_main.name = "DialogueEditor"
	get_editor_interface().get_editor_viewport().add_child(_dialogue_main)
	_dialogue_main.set_editor(self)
	make_visible(false)
	add_custom_type("Dialogue2D", "Area2D", DialogueDialogue2D, DialogueIcon)
	add_custom_type("Dialogue3D", "Area", DialogueDialogue3D, DialogueIcon)
	_dialogue_editor_plugin = preload("res://addons/dialogue_editor/inspectors/DialogueMangerDialoguesInspectorPlugin.gd").new()
	add_inspector_plugin(_dialogue_editor_plugin)

func _exit_tree():
	if _dialogue_main:
		_dialogue_main.queue_free()
	remove_custom_type("Dialogue2D")
	remove_custom_type("Dialogue3D")
	remove_inspector_plugin(_dialogue_editor_plugin)

func has_main_screen():
	return true

func make_visible(visible):
	if _dialogue_main:
		_dialogue_main.visible = visible

func get_plugin_name():
	return "Dialogue"

func get_plugin_icon():
	return IconResource

func save_external_data():
	if _dialogue_main:
		_dialogue_main.save_data()
