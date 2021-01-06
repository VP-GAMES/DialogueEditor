# Dialogues preview dialog text for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

signal delete_action

var _index
var _scene

onready var _text_ui = $Text as LineEdit
onready var _delete_ui = $Delete as Button

func set_data(index: int, scene) -> void:
	_index = index
	_scene = scene
	_init_connections()
	_draw_view()

func _init_connections() -> void:
	if not _text_ui.is_connected("text_changed", self, "_on_text_changed"):
		_text_ui.connect("text_changed", self, "_on_text_changed")
	if not _delete_ui.is_connected("pressed", self, "_on_delete_pressed"):
		_delete_ui.connect("pressed", self, "_on_delete_pressed")

func _on_text_changed(new_text: String) -> void:
	if _scene.has("preview") and _scene["preview"].has("texts"):
		_scene["preview"]["texts"][_index] = new_text

func _on_delete_pressed() -> void:
	if _scene.has("preview") and _scene["preview"].has("texts"):
		_scene["preview"]["texts"].remove(_index)
		emit_signal("delete_action")

func _draw_view() -> void:
	if _scene.has("preview") and _scene["preview"].has("texts"):
		_text_ui.text = _scene["preview"]["texts"][_index]
