# Node sentence panel for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends PanelContainer
class_name DialoguePanelSentence

var _group: ButtonGroup
var _data: DialogueData
var _node: DialogueNode
var _sentence: Dictionary
var _dialogue: DialogueDialogue
var localization_editor

onready var _remove_ui = $VBox/HBox/Remove as Button
onready var _event_ui = $VBox/HBox/Event as Button
onready var _select_ui = $VBox/HBox/Select as Button
onready var _text_ui = $VBox/HBox/Text as LineEdit
onready var _dropdown_ui = $VBox/HBox/Dropdown
onready var _event_box_ui = $VBox/HBoxEvent as HBoxContainer
onready var _event_text_ui = $VBox/HBoxEvent/EventText as LineEdit

const IconResourceEvent = preload("res://addons/dialogue_editor/icons/Event.png")
const IconResourceEventEmpty = preload("res://addons/dialogue_editor/icons/EventEmpty.png")

func sentence() -> Dictionary:
	return _sentence

func set_data(group: ButtonGroup, sentence: Dictionary, node: DialogueNode, dialogue: DialogueDialogue, data: DialogueData) -> void:
	_group = group
	_sentence = sentence
	_node = node
	_dialogue = dialogue
	_data = data
	_dropdown_ui_init()
	_init_connections()
	_update_view()
	_dropdown_ui.set_data(_data)

func _process(delta: float) -> void:
	if not localization_editor:
		_dropdown_ui_init()

func _dropdown_ui_init() -> void:
	if not localization_editor:
		localization_editor = get_tree().get_root().find_node("LocalizationEditor", true, false)
	if localization_editor:
		var data = localization_editor.get_data()
		if data:
			if not data.is_connected("data_changed", self, "_on_localization_data_changed"):
				data.connect("data_changed", self, "_on_localization_data_changed")
			if not data.is_connected("data_key_value_changed", self, "_on_localization_data_changed"):
				data.connect("data_key_value_changed", self, "_on_localization_data_changed")
			_on_localization_data_changed()

func _on_localization_data_changed() -> void:
	if _dropdown_ui:
		_dropdown_ui.clear()
		for key in localization_editor.get_data().data.keys:
			_dropdown_ui.add_item(key.value)
		_dropdown_ui.set_selected_by_value(_sentence.text)

func _init_connections() -> void:
	if not _remove_ui.is_connected("pressed", self, "_on_remove_sentence_pressed"):
		assert(_remove_ui.connect("pressed", self, "_on_remove_sentence_pressed") == OK)
	if not _select_ui.is_connected("pressed", self, "_on_select_sentence_pressed"):
		assert(_select_ui.connect("pressed", self, "_on_select_sentence_pressed") == OK)
	if not _text_ui.is_connected("text_changed", self, "_on_text_changed"):
		assert(_text_ui.connect("text_changed", self, "_on_text_changed") == OK)
	if not _event_text_ui.is_connected("text_changed", self, "_on_event_text_changed"):
		assert(_event_text_ui.connect("text_changed", self, "_on_event_text_changed") == OK)
	if not _event_ui.is_connected("pressed", self, "_on_select_event_pressed"):
		assert(_event_ui.connect("pressed", self, "_on_select_event_pressed") == OK)
	if not _node.is_connected("sentence_event_changed", self, "_on_sentence_event_changed"):
		assert(_node.connect("sentence_event_changed", self, "_on_sentence_event_changed") == OK)
	if _data.setting_localization_editor_enabled():
		if not _dropdown_ui.is_connected("selection_changed_value", self, "_on_selection_changed_value"):
			assert(_dropdown_ui.connect("selection_changed_value", self, "_on_selection_changed_value") == OK)

func _on_remove_sentence_pressed() -> void:
	_node.del_sentence(_sentence)

func _on_select_event_pressed() -> void:
	_node.select_sentence_event_visibility(_sentence, _event_ui.is_pressed())

func _on_text_changed(new_text: String) -> void:
	_node.change_sentence_text(_sentence, new_text)

func _on_event_text_changed(new_text: String) -> void:
	_node.change_sentence_event(_sentence, new_text)

func _on_sentence_event_visibility_changed(sentence) -> void:
	if _sentence == sentence:
		_update_view()

func _on_select_sentence_pressed() -> void:
	_node.select_sentence(_sentence)

func _on_sentence_event_changed(sentence) -> void:
	_event_ui_draw()

func _on_selection_changed_value(new_text: String) -> void:
	_node.change_sentence_text(_sentence, new_text)

func _update_view() -> void:
	_remove_ui_draw()
	_event_ui_draw()
	_select_ui_draw()
	_text_ui_draw()
	_dropdown_ui_draw()
	_event_box_ui_draw()
	_event_text_ui_draw()
	rect_size = Vector2.ZERO

func _remove_ui_draw() -> void:
	_remove_ui.visible = _node.sentences.size() > 1

func _event_ui_draw() -> void:
	_event_ui.set_pressed(_sentence.has("event_visible") and _sentence.event_visible)
	if _sentence.event.empty():
		_event_ui.set_button_icon(IconResourceEventEmpty)
	else:
		_event_ui.set_button_icon(IconResourceEvent)

func _select_ui_draw() -> void:
	_select_ui.set_button_group(_group)
	_select_ui.visible = _node.sentences.size() > 1
	if _sentence == _node.selected_sentence():
		_select_ui.set_pressed(true)

func _text_ui_draw() -> void:
	_text_ui.visible = not _data.setting_localization_editor_enabled()
	_text_ui.text = _sentence.text

func _dropdown_ui_draw() -> void:
	_dropdown_ui.visible = _data.setting_localization_editor_enabled()

func _event_box_ui_draw() -> void:
	_event_box_ui.visible = _sentence.has("event_visible") and _sentence.event_visible

func _event_text_ui_draw() -> void:
	_event_text_ui.text = _sentence.event

func _draw():
	if _sentence.has("event_visible") and _sentence.event_visible:
		var stylebox = get_stylebox("panel", "PanelContainer")
		var x = _event_ui.rect_position.x + _event_ui.rect_size.x / 2 + stylebox.content_margin_left
		var y = _event_ui.rect_position.y +_remove_ui.rect_size.y / 2 + stylebox.content_margin_top
		var x_end = _remove_ui.rect_size.x + _event_ui.rect_position.x + stylebox.content_margin_left * 2
		var y_end = _remove_ui.rect_size.y +  _event_text_ui.rect_size.y / 2 + stylebox.content_margin_top * 2
		draw_line(Vector2(x, y), Vector2(x, y_end), Color.white, 2)
		draw_line(Vector2(x, y_end), Vector2(x_end, y_end), Color.white, 2)
