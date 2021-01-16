# Node sentence for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends "res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/NodeBase.gd"

var _data: DialogueData
var _node: DialogueNode
var _dialogue: DialogueDialogue
var _group = ButtonGroup.new()

onready var _add_ui = $PanelActor/HBox/Add as Button
onready var _actors_ui = $PanelActor/HBox/Actor as OptionButton
onready var _view_ui = $PanelTexture/HBoxTexture/View as Button
onready var _textures_ui = $PanelTexture/HBoxTexture/Texture as OptionButton
onready var _texture_ui = $Center/Texture

const PanelSentence = preload("res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/node_sentence/PanelSentence.tscn")

func node() -> DialogueNode:
	return _node

func set_data(node: DialogueNode, dialogue: DialogueDialogue, data: DialogueData) -> void:
	_node = node
	_dialogue = dialogue
	_data = data
	_check_ui()
	_init_connections()
	_update_view()

func _check_ui() -> void:
	offset = _node.position
	_view_ui.set_pressed(_node.texture_view)

func _init_connections() -> void:
	if not _actors_ui.is_connected("item_selected", self, "_on_item_actor_selected"):
		assert(_actors_ui.connect("item_selected", self, "_on_item_actor_selected") == OK)
	if not _textures_ui.is_connected("item_selected", self, "_on_item_textures_selected"):
		assert(_textures_ui.connect("item_selected", self, "_on_item_textures_selected") == OK)
	if not _view_ui.is_connected("pressed", self, "_on_view_pressed"):
		assert(_view_ui.connect("pressed", self, "_on_view_pressed") == OK)

func _on_item_actor_selected(index: int) -> void:
	if index > 0:
		_node.actor = _data.actors[index - 1]
	else:
		_node.actor = null
	_textures_ui_fill_and_draw()
	_texture_ui_fill_and_draw()

func _on_item_textures_selected(index: int) -> void:
	if index > 0:
		_node.texture_uuid = _node.actor.resources[index - 1].uuid
	else:
		_node.texture_uuid = null
	_texture_ui_fill_and_draw()

func _on_view_pressed() -> void:
	_texture_ui_fill_and_draw()

func _update_view() -> void:
	_draw_view()

func _draw_view() -> void:
	_actors_ui_fill_and_draw()
	_textures_ui_fill_and_draw()
	_texture_ui_fill_and_draw()

func _actors_ui_fill_and_draw() -> void:
	_actors_ui.clear()
	_actors_ui.disabled = true
	var select = -1
	if not _data.actors.empty():
		_actors_ui.disabled = false
		_actors_ui.add_item("None", 0)
		select = 0
		for index in range(_data.actors.size()):
			var actor = _data.actors[index]
			if _node.actor == actor:
				select = index + 1
			if not actor.resources.empty():
				var image = load(actor.resources[0].path)
				image = _data.resize_texture(image, Vector2(16, 16))
				_actors_ui.add_icon_item(image, actor.name, index)
			else:
				_actors_ui.add_item(actor.name, index + 1)
		_actors_ui.select(select)

func _textures_ui_fill_and_draw() -> void:
	_textures_ui.clear()
	_textures_ui.disabled = true
	var select = -1
	if _node.actor:
		if not _node.actor.resources.empty():
			_textures_ui.disabled = false
			_textures_ui.add_item("None", 0)
			select = 0
			for index in range(_node.actor.resources.size()):
				var resource = _node.actor.resources[index]
				if _node.texture_uuid == resource.uuid:
					select = index + 1
				_textures_ui.add_item(resource.name, index + 1)
			_textures_ui.select(select)

func _texture_ui_fill_and_draw() -> void:
	var texture = null
	if _node.actor:
		texture = _node.actor.resource_by_uuid(_node.texture_uuid, false)
	_texture_ui.texture = texture
	_view_ui.set_disabled(texture == null)
	_texture_ui.visible = texture != null and _view_ui.pressed
	if not texture:
		_view_ui.set_pressed(false)
	_node.texture_view = _view_ui.pressed
	rect_size = Vector2.ZERO

#func _ready() -> void:
#	_group.resource_local_to_scene = false
#	set_slot(0, true, 0, Color.white, false, 0, Color.white)
#	_sentence_add()
#	_init_connections()

#func _init_connections() -> void:
#	_add_ui.connect("pressed", self, "_sentence_add")
#	connect("resize_request", self, "_on_resize_request")
	
func _on_resize_request(new_minsize: Vector2):
	print(new_minsize)

func _sentence_add() -> void:
	var sentence = PanelSentence.instance()
	var select = sentence.get_node("HBox/Select") as CheckBox
	select.set_button_group(_group)
	select.connect("pressed", self, "_on_select_changed")
	var remove =  sentence.get_node("HBox/Remove") as Button
	add_child(sentence)
	remove.connect("pressed", self, "_sentence_remove", [sentence.get_instance_id()])
	set_slot(get_child_count() - 1, false, 0, Color.white, true, 0, Color.white)
	_check_first_sentence_view()

func _sentence_remove(id: int) -> void:
	var children = get_children();
	for i in range(2, get_child_count()):
		if id == children[i].get_instance_id():
			if children[i].get_node("HBox/Select").is_pressed():
				_sentence_deselect(id)
			_sentence_remove_connection(i - 2)
			children[i].connect("tree_exited", self, "_sentence_remove_done", [i - 2])
			children[i].queue_free()
			break
	clear_slot(get_child_count() - 1)

func _sentence_remove_connection(idx: int) -> void:
	var last_to
	var last_to_port
	for s in range(get_child_count(), idx - 1, -1):
		for i in get_parent().get_connection_list():
			if i.from == self.name and i.from_port == s:
				get_parent().disconnect_node(i.from, i.from_port, i.to, i.to_port)
				if last_to:
					get_parent().connect_node(i.from, i.from_port, last_to, last_to_port)
				last_to = i.to
				last_to_port = i.to_port

func _sentence_deselect(id: int ) -> void:
	var children = get_children();
	for i in range(2, get_child_count()):
		if id != get_child(i).get_instance_id():
			get_child(i).get_node("HBox/Select").set_pressed(true)
			return

func _sentence_remove_done(idx:int) -> void:
	rect_size = Vector2.ZERO
	_check_first_sentence_view()

func _check_first_sentence_view() -> void:
	var sentence = get_children()[2] 
	if get_child_count() <= 3:
		sentence.get_node("HBox/Select").set_pressed(true)
		sentence.get_node("HBox/Remove").hide()
		sentence.get_node("HBox/Select").hide()
	elif get_child_count() == 4:
		sentence.get_node("HBox/Remove").show()
		sentence.get_node("HBox/Select").show()

func selected_slot() -> Vector2:
	var count = 0
	for i in range(2, get_child_count()):
		if get_child(i).get_node("HBox/Select").is_pressed():
			return Vector2(count, i)
		count += 1
	return Vector2.ZERO

func _on_select_changed() -> void:
	get_parent().get_parent().nodes_colors_update()

func save_data():
	var sentences: Array
	var children = get_children();
	for i in range(2, get_child_count()):
		var text = children[i].get_node("HBox/LineEdit").text
		sentences.append(text)
	var dict = {
		"filename" : get_filename(),
		"name" : name,
		"editor_position": global_position(),
		"sentences": sentences
		}
	return dict

func load_data(dict):
	if dict.sentences.size() > 1:
		for i in range(1, dict.sentences.size()):
			_sentence_add()
	var count = 0
	var children = get_children();
	for i in range(2, get_child_count()):
		children[i].get_node("HBox/LineEdit").text = dict.sentences[count]
