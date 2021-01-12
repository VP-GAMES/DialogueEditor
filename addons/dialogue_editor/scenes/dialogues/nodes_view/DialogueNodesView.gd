# DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends Control

var _data: DialogueData
var _undo_redo: UndoRedo

var colorDef = Color(1, 1, 1)
var colorPath = Color(0.4, 0.78, 0.945)

var _selected_dialogue: DialogueDialogue
var _selected_node: Node
var _mouse_position: Vector2
var _mouse_over_popup = false
var _moved_node_start_offset: Vector2

onready var _graph_ui = $Graph as GraphEdit
onready var _popup_ui = $Popup as PopupMenu

const uuid_gen = preload("res://addons/dialogue_editor/uuid/uuid.gd")

const NodeStart = preload("res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/node_start/NodeStart.tscn")
const NodeSentence = preload("res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/node_sentence/NodeSentence.tscn")
const NodeEnd = preload("res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/node_end/NodeEnd.tscn")

func set_data(data: DialogueData) -> void:
	_data = data
	_undo_redo = _data.undo_redo()
	_selected_dialogue = _data.selected_dialogue()
	_init_connections()
	_init_dialogue()

func _init_dialogue():
	_delete_nodes()
	if _selected_dialogue:
		_graph_ui.scroll_offset = _selected_dialogue.scrolloffset
		for node in _selected_dialogue.nodes:
			var newNode = load(node.filename).instance()
			newNode.name = node.name
			newNode.offset = _to_graph_position(node.editor_position)
			_graph_ui.add_child(newNode, true)
			if newNode.has_method("set_undo_redo"):
				newNode.set_undo_redo(_undo_redo)
			if newNode.has_method("load_data"):
				newNode.load_data(node)
		for node in _selected_dialogue.connections:
			_graph_ui.connect_node(node.from, node.from_port, node.to, node.to_port)
		nodes_colors_update()


func _to_graph_position(global_position : Vector2) -> Vector2:
	return (global_position + _graph_ui.scroll_offset) / _graph_ui.zoom

func _init_connections() -> void:
	assert(_graph_ui.connect("node_selected", self, "_on_node_selected") == OK)
	assert(_graph_ui.connect("_begin_node_move", self, "_on_node_begin_move") == OK)
	assert(_graph_ui.connect("_end_node_move", self, "_on_node_end_move") == OK)
	assert(_popup_ui.connect("mouse_entered", self, "_on_mouse_popup_entered") == OK)
	assert(_popup_ui.connect("mouse_exited", self, "_on_mouse_popup_exited") == OK)
	assert(_graph_ui.connect("gui_input", self, "_on_gui_input") == OK)
	assert(_popup_ui.connect("id_pressed", self, "_on_popup_item_selected") == OK)
	assert(_graph_ui.connect("connection_request", self, "_node_connection_request") == OK)
	assert(_graph_ui.connect("disconnection_request", self, "_node_disconnection_request") == OK)

func _on_node_selected(node: Node) -> void:
	_selected_node = node

func _on_node_begin_move() -> void:
	_moved_node_start_offset = _selected_node.offset

func _on_node_end_move() -> void:
	if _undo_redo == null:
		return
	_undo_redo.create_action("Move " + _selected_node.name)
	_undo_redo.add_do_property(_selected_node, "offset", _selected_node.offset)
	_undo_redo.add_undo_property(_selected_node, "offset", _moved_node_start_offset)
	_undo_redo.commit_action()

func _on_mouse_popup_entered() -> void:
	_mouse_over_popup = true

func _on_mouse_popup_exited() -> void:
	_mouse_over_popup = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			if _popup_ui.visible and not _mouse_over_popup:
				_popup_ui.hide()

func _on_gui_input(event: InputEvent) -> void:
	if _selected_dialogue:
		if event is InputEventMouseButton:
			if event.get_button_index() == BUTTON_RIGHT and event.pressed:
				_mouse_position = event.position
				_show_popup()
			elif event.get_button_index() == BUTTON_LEFT and event.pressed:
				if _popup_ui.visible and not _mouse_over_popup:
					_popup_ui.hide()
		if event is InputEventKey and _selected_node:
			if event.scancode == KEY_DELETE and  event.pressed:
				_delete_selected_node()

func _show_popup() -> void:
	_build_popup()
	_popup_ui.set_position(_calc_popup_position())
	_popup_ui.rect_size = Vector2.ZERO
	_popup_ui.show()

func _build_popup():
	_popup_ui.clear()
	_build_popup_node_start()
	_build_popup_node_sentence()
	_build_popup_node_end()
	_popup_ui.add_separator()
	_build_popup_delete_nodes()

func _build_popup_node_start() -> void:
	if get_node_or_null("Graph/NodeStart") == null:
		_popup_ui.add_item("Start", 1)
		
func _build_popup_node_sentence() -> void:
	_popup_ui.add_item("Sentence", 2)

func _build_popup_node_end() -> void:
	if get_node_or_null("Graph/NodeEnd") == null:
		_popup_ui.add_item("End", 3)

func _build_popup_delete_nodes() -> void:
	_popup_ui.add_item("Clear All", 4)

func _calc_popup_position() -> Vector2:
	var pos_x = _graph_ui.rect_global_position.x + _mouse_position.x
	var pos_y = _graph_ui.rect_global_position.y + _mouse_position.y
	return Vector2(pos_x, pos_y)

func _on_popup_item_selected(id: int):
	var offset = _calc_node_position()
	if id == 1:
		_node_start_add()
	elif id == 2:
		_node_sentence_add()
	elif id == 3:
		_node_end_add()
	elif id == 4:
		_delete_nodes()

func _calc_node_position() -> Vector2:
	var offset_x = (_graph_ui.scroll_offset.x + _mouse_position.x) / _graph_ui.get_zoom()
	var offset_y = (_graph_ui.scroll_offset.y + _mouse_position.y) / _graph_ui.get_zoom()
	return Vector2(offset_x, offset_y)

# *** NodeStart ***
func _node_start_add() -> void:
	if _undo_redo == null:
		_node_start_add_do()
	else:
		_undo_redo.create_action("Add NodeStart")
		_undo_redo.add_do_method(self, "_node_start_add_do")
		_undo_redo.add_undo_method(self, "_node_start_add_undo")
		_undo_redo.commit_action()

func _node_start_add_do() -> void:
	var node_start = NodeStart.instance()
	node_start.offset = _calc_node_position()
	_graph_ui.add_child(node_start)

func _node_start_add_undo() -> void:
	var node = _node_find_by_name("NodeStart")
	_delete_node(node)

# *** NodeSentence ***
func _node_sentence_add() -> void:
	var uuid = uuid_gen.v4()
	if _undo_redo == null:
		_node_sentence_add_do(uuid)
	else:
		_undo_redo.create_action("Add NodeSentence")
		_undo_redo.add_do_method(self, "_node_sentence_add_do", uuid)
		_undo_redo.add_undo_method(self, "_node_sentence_add_undo", uuid)
		_undo_redo.commit_action()

func _node_sentence_add_do(uuid: String) -> void:
	var node_sentence = NodeSentence.instance()
	node_sentence.offset = _calc_node_position()
	node_sentence.uuid = uuid
	_graph_ui.add_child(node_sentence)

func _node_sentence_add_undo(uuid) -> void:
	var node_sentence = _node_find_by_uuid(uuid)
	_delete_node(node_sentence)

# *** NodeEnd ***
func _node_end_add() -> void:
	if _undo_redo == null:
		_node_end_add_do()
	else:
		_undo_redo.create_action("Add NodeEnd")
		_undo_redo.add_do_method(self, "_node_end_add_do")
		_undo_redo.add_undo_method(self, "_node_end_add_undo")
		_undo_redo.commit_action()

func _node_end_add_do() -> void:
	var node_end = NodeEnd.instance()
	node_end.offset = _calc_node_position()
	_graph_ui.add_child(node_end)

func _node_end_add_undo() -> void:
	var node = _node_find_by_name("NodeEnd")
	_delete_node(node)

# *** Nodes control ***
func _node_find_by_name(name: String) -> GraphNode:
	for node in _graph_ui.get_children():
		if node.name == name:
			return node
	return null

func _node_find_by_uuid(uuid: String) -> GraphNode:
	for node in _graph_ui.get_children():
		if "uuid" in node and node.uuid == uuid:
			return node
	return null

func _delete_selected_node() -> void:
	_delete_node(_selected_node)

func _delete_nodes() -> void:
	_graph_ui.clear_connections()
	for node in _graph_ui.get_children():
		if node is GraphNode:
			_graph_ui.remove_child(node)
			node.queue_free()

func _delete_node(node) -> void:
	_remove_all_connections(node)
	_graph_ui.remove_child(node)
	node.queue_free()

func _node_connection_request(from, from_slot, to, to_slot):
	if from == to: 
		return
	if from == "NodeStart" and to == "NodeEnd": 
		return
	if from == "NodeStart":
		for i in _graph_ui.get_connection_list():
			if i.to == to and i.to_port == to_slot:
				_graph_ui.disconnect_node(i.from, i.from_port, i.to, i.to_port)
	for i in _graph_ui.get_connection_list():
		if i.to == to and i.to_port == to_slot and i.from == "NodeStart":
			_graph_ui.disconnect_node(i.from, i.from_port, i.to, i.to_port)
	for i in _graph_ui.get_connection_list():
		if i.from == from and i.from_port == from_slot:
			_graph_ui.disconnect_node(i.from, i.from_port, i.to, i.to_port)
	_graph_ui.connect_node(from, from_slot, to, to_slot)
	nodes_colors_update()

func _node_disconnection_request(from, from_slot, to, to_slot):
	print("DISCONNECT")
	if _undo_redo == null:
		_node_disconnection_do(from, from_slot, to, to_slot)
	else:
		var actionName = "Disconnect " + from + ":" + str(from_slot)
		actionName += " -X- " + to + ":" + str(to_slot)
		_undo_redo.create_action(actionName)
		_undo_redo.add_do_method(self, "_node_disconnection_do", from, from_slot, to, to_slot)
		_undo_redo.add_undo_method(self, "_node_disconnection_undo", from, from_slot, to, to_slot)
		_undo_redo.commit_action()

func _node_disconnection_do(from, from_slot, to, to_slot):
	_graph_ui.disconnect_node(from, from_slot, to, to_slot)
	yield(get_tree().create_timer(.1), "timeout")
	#nodes_colors_update()

func _node_disconnection_undo(from, from_slot, to, to_slot):
	_graph_ui.connect_node(from, from_slot, to, to_slot)
	yield(get_tree().create_timer(.1), "timeout")
	#nodes_colors_update()

func _remove_all_connections(node):
	for i in _graph_ui.get_connection_list():
		if i.from == node.name or i.to == node.name:
			_graph_ui.disconnect_node(i.from, i.from_port, i.to, i.to_port)

func nodes_colors_update() -> void:
	_nodes_color_to_default()
	_nodes_color_by_path()
	_graph_ui.hide()
	_graph_ui.show()

func _nodes_color_to_default() -> void:
	for node in _graph_ui.get_children():
		if node is GraphNode:
			_node_color_to_default(node)

func _node_color_to_default(node: GraphNode) -> void:
	var count = node.get_child_count()
	for node_slot in range(count):
		_color_node_slots_path(node, node_slot, colorDef)

func _nodes_color_by_path() -> void:
	var node_next = _next_node()
	while(node_next != null):
		_color_node_slots_path(node_next, 0, colorPath)
		var node_slot = node_next.selected_slot()
		_color_node_slots_path(node_next, node_slot.y, colorPath)
		node_next = _next_node(node_next, node_slot.x)

func _next_node(from: GraphNode = null, from_port = 0) -> GraphNode:
	if from == null:
		return _node_find_by_name("NodeStart")
	for i in _graph_ui.get_connection_list():
		if i.from == from.name and i.from_port == from_port:
			for node in _graph_ui.get_children():
				if node is GraphNode and node.name == i.to:
					return node
	return null

func _color_node_slots_path(node: GraphNode, node_slot: int, color) -> void:
	if node.is_slot_enabled_left(node_slot):
		node.set_slot(node_slot, true, 0, color, false, 0, color)
	if node.is_slot_enabled_right(node_slot):
		node.set_slot(node_slot, false, 0, color, true, 0, color)

func hide() -> void:
	_popup_ui.hide()
	self.hide()

func _sync_dialogue_data() -> void:
	if _nodes_count() <= 0:
		return
	_selected_dialogue.nodes.clear()
	_selected_dialogue.connections.clear()
	_selected_dialogue.scrolloffset = _graph_ui.scroll_offset
	for node in _graph_ui.get_children():
		if node is GraphNode and node.has_method("save_data"):
			_selected_dialogue.nodes.append(node.save_data())
	_selected_dialogue.connections = _graph_ui.get_connection_list()

func _nodes_count() ->  int:
	var count = 0
	for node in _graph_ui.get_children():
		if node is GraphNode:
			count += 1
	return count
