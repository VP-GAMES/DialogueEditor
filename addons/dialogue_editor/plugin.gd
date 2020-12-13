# Plugin DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends EditorPlugin

const IconResource = preload("res://addons/dialogue_editor/icons/Dialogue.png")
const DialogueMain = preload("res://addons/dialogue_editor/DialogueEditor.tscn")

var _dialogue_main

func _enter_tree():
	_dialogue_main = DialogueMain.instance()
	get_editor_interface().get_editor_viewport().add_child(_dialogue_main)
	_dialogue_main.set_editor(self)
	make_visible(false)

func _exit_tree():
	if _dialogue_main:
		_dialogue_main.queue_free()

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
