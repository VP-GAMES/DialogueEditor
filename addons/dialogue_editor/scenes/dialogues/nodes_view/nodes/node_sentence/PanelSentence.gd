# Node panel for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends PanelContainer
class_name DialoguePanelSentence

var _group: ButtonGroup
var _data: DialogueData
var _node: DialogueNode
var _sentence: Dictionary
var _dialogue: DialogueDialogue

onready var _remove_ui = $VBox/HBox/Remove as Button
onready var _event_ui = $VBox/HBox/Event as Button
onready var _select_ui = $VBox/HBox/Select as Button
onready var _text_ui = $VBox/HBox/Text as LineEdit
onready var _event_box_ui = $VBox/HBoxEvent as HBoxContainer
onready var _event_text_ui = $VBox/HBoxEvent/EventText as LineEdit

const IconResourceEvent = preload("res://addons/dialogue_editor/icons/Event.png")
const IconResourceEventEmpty = preload("res://addons/dialogue_editor/icons/EventEmpty.png")

func set_data(group: ButtonGroup, sentence: Dictionary, node: DialogueNode, dialogue: DialogueDialogue, data: DialogueData) -> void:
	_group = group
	_sentence = sentence
	_node = node
	_dialogue = dialogue
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _remove_ui.is_connected("pressed", self, "_on_remove_sentence_pressed"):
		assert(_remove_ui.connect("pressed", self, "_on_remove_sentence_pressed") == OK)
	if not _event_ui.is_connected("pressed", self, "_on_select_event_pressed"):
		assert(_event_ui.connect("pressed", self, "_on_select_event_pressed") == OK)
	if not _select_ui.is_connected("pressed", self, "_on_select_sentence_pressed"):
		assert(_select_ui.connect("pressed", self, "_on_select_sentence_pressed") == OK)
	if not _text_ui.is_connected("text_changed", self, "_on_text_changed"):
		assert(_text_ui.connect("text_changed", self, "_on_text_changed") == OK)
	if not _event_text_ui.is_connected("text_changed", self, "_on_event_text_changed"):
		assert(_event_text_ui.connect("text_changed", self, "_on_event_text_changed") == OK)
	if not _node.is_connected("sentence_event_changed", self, "_on_sentence_event_changed"):
		assert(_node.connect("sentence_event_changed", self, "_on_sentence_event_changed") == OK)

func _on_remove_sentence_pressed() -> void:
	_node.del_sentence(_sentence)

func _on_select_event_pressed() -> void:
	_node.select_sentence_event_visibility(_sentence, _event_ui.is_pressed())

func _on_sentence_event_visibility_changed(sentence) -> void:
	if _sentence == sentence:
		_update_view()

func _on_select_sentence_pressed() -> void:
	_node.select_sentence(_sentence)

func _on_text_changed(new_text: String) -> void:
	_node.change_sentence_text(_sentence, new_text)

func _on_event_text_changed(new_text: String) -> void:
	_node.change_sentence_event(_sentence, new_text)

func _on_sentence_event_changed(sentence) -> void:
	_event_ui_draw()

func _update_view() -> void:
	_remove_ui_draw()
	_event_ui_draw()
	_select_ui_draw()
	_text_ui_draw()
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
	_text_ui.text = _sentence.text

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

#func _ready() -> void:
#	_group.resource_local_to_scene = false
#	set_slot(0, true, 0, Color.white, false, 0, Color.white)
#	_sentence_add()
#	_init_connections()

#func _init_connections() -> void:
#	_add_ui.connect("pressed", self, "_sentence_add")
#	connect("resize_request", self, "_on_resize_request")

#func _on_resize_request(new_minsize: Vector2):
#	print(new_minsize)
#
#func _sentence_add() -> void:
#	var sentence = PanelSentence.instance()
#	var select = sentence.get_node("HBox/Select") as CheckBox
#	select.set_button_group(_group)
#	select.connect("pressed", self, "_on_select_changed")
#	var remove =  sentence.get_node("HBox/Remove") as Button
#	add_child(sentence)
#	remove.connect("pressed", self, "_sentence_remove", [sentence.get_instance_id()])
#	set_slot(get_child_count() - 1, false, 0, Color.white, true, 0, Color.white)
#	_check_first_sentence_view()
#
#func _sentence_remove(id: int) -> void:
#	var children = get_children();
#	for i in range(2, get_child_count()):
#		if id == children[i].get_instance_id():
#			if children[i].get_node("HBox/Select").is_pressed():
#				_sentence_deselect(id)
#			_sentence_remove_connection(i - 2)
#			children[i].connect("tree_exited", self, "_sentence_remove_done", [i - 2])
#			children[i].queue_free()
#			break
#	clear_slot(get_child_count() - 1)
#
#func _sentence_remove_connection(idx: int) -> void:
#	var last_to
#	var last_to_port
#	for s in range(get_child_count(), idx - 1, -1):
#		for i in get_parent().get_connection_list():
#			if i.from == self.name and i.from_port == s:
#				get_parent().disconnect_node(i.from, i.from_port, i.to, i.to_port)
#				if last_to:
#					get_parent().connect_node(i.from, i.from_port, last_to, last_to_port)
#				last_to = i.to
#				last_to_port = i.to_port
#
#func _sentence_deselect(id: int ) -> void:
#	var children = get_children();
#	for i in range(2, get_child_count()):
#		if id != get_child(i).get_instance_id():
#			get_child(i).get_node("HBox/Select").set_pressed(true)
#			return
#
#func _sentence_remove_done(idx:int) -> void:
#	rect_size = Vector2.ZERO
#	_check_first_sentence_view()
#
#func _check_first_sentence_view() -> void:
#	var sentence = get_children()[2] 
#	if get_child_count() <= 3:
#		sentence.get_node("HBox/Select").set_pressed(true)
#		sentence.get_node("HBox/Remove").hide()
#		sentence.get_node("HBox/Select").hide()
#	elif get_child_count() == 4:
#		sentence.get_node("HBox/Remove").show()
#		sentence.get_node("HBox/Select").show()
#
#func selected_slot() -> Vector2:
#	var count = 0
#	for i in range(2, get_child_count()):
#		if get_child(i).get_node("HBox/Select").is_pressed():
#			return Vector2(count, i)
#		count += 1
#	return Vector2.ZERO
#
#func _on_select_changed() -> void:
#	get_parent().get_parent().nodes_colors_update()
#
#func save_data():
#	var sentences: Array
#	var children = get_children();
#	for i in range(2, get_child_count()):
#		var text = children[i].get_node("HBox/LineEdit").text
#		sentences.append(text)
#	var dict = {
#		"filename" : get_filename(),
#		"name" : name,
#		"editor_position": global_position(),
#		"sentences": sentences
#		}
#	return dict
#
#func load_data(dict):
#	if dict.sentences.size() > 1:
#		for i in range(1, dict.sentences.size()):
#			_sentence_add()
#	var count = 0
#	var children = get_children();
#	for i in range(2, get_child_count()):
#		children[i].get_node("HBox/LineEdit").text = dict.sentences[count]
