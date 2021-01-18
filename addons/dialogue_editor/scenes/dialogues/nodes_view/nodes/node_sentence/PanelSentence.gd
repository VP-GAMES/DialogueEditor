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

onready var _remove_ui = $HBox/Remove as Button
onready var _select_ui = $HBox/Select as Button
onready var _text_ui = $HBox/Text as LineEdit

func set_data(group: ButtonGroup, sentence: Dictionary, node: DialogueNode, dialogue: DialogueDialogue, data: DialogueData) -> void:
	_group = group
	_sentence = sentence
	_node = node
	_dialogue = dialogue
	_data = data
	_check_ui()
	_init_connections()

func _check_ui() -> void:
	_remove_ui.visible = _node.sentences.size() > 1
	_select_ui.set_button_group(_group)
	_select_ui.visible = _node.sentences.size() > 1
	if _sentence == _node.selected_sentence():
		_select_ui.set_pressed(true)

func _init_connections() -> void:
	if not _remove_ui.is_connected("pressed", self, "_on_remove_sentence_pressed"):
		assert(_remove_ui.connect("pressed", self, "_on_remove_sentence_pressed") == OK)
	if not _select_ui.is_connected("pressed", self, "_on_select_sentence_pressed"):
		assert(_select_ui.connect("pressed", self, "_on_select_sentence_pressed") == OK)

func _on_remove_sentence_pressed() -> void:
	_node.del_sentence(_sentence)

func _on_select_sentence_pressed() -> void:
	_node.select_sentence(_sentence)

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
