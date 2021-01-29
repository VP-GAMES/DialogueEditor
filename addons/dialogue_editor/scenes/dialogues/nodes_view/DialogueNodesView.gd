# Nodes view for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends Control

var _data: DialogueData
var _dialogue: DialogueDialogue

var _mouse_position: Vector2
var _mouse_over_popup = false
var _selected_node: Node

onready var _graph_ui = $Graph as GraphEdit
onready var _popup_ui = $Popup as PopupMenu

const NodeStart = preload("res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/node_start/NodeStart.tscn")
const NodeSentence = preload("res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/node_sentence/NodeSentence.tscn")
const NodeEnd = preload("res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/node_end/NodeEnd.tscn")

func set_data(dialogue: DialogueDialogue, data: DialogueData) -> void:
	if dialogue:
		_dialogue = dialogue
		_data = data
		_graph_ui.scroll_offset = _dialogue.scroll_offset
		_init_connections()
		_update_view()

func _init_connections() -> void:
	if not _graph_ui.is_connected("scroll_offset_changed", self, "_on_scroll_offset_changed"):
		assert(_graph_ui.connect("scroll_offset_changed", self, "_on_scroll_offset_changed") == OK)
	if not _graph_ui.is_connected("node_selected", self, "_on_node_selected"):
		assert(_graph_ui.connect("node_selected", self, "_on_node_selected") == OK)
	if not _graph_ui.is_connected("connection_request", self, "_node_connection_request"):
		assert(_graph_ui.connect("connection_request", self, "_node_connection_request") == OK)
	if not _graph_ui.is_connected("disconnection_request", self, "_node_disconnection_request"):
		assert(_graph_ui.connect("disconnection_request", self, "_node_disconnection_request") == OK)
	if not _popup_ui.is_connected("mouse_entered", self, "_on_mouse_popup_entered"):
		assert(_popup_ui.connect("mouse_entered", self, "_on_mouse_popup_entered") == OK)
	if not _popup_ui.is_connected("mouse_exited", self, "_on_mouse_popup_exited"):
		assert(_popup_ui.connect("mouse_exited", self, "_on_mouse_popup_exited") == OK)
	if not _graph_ui.is_connected("gui_input", self, "_on_gui_input"):
		assert(_graph_ui.connect("gui_input", self, "_on_gui_input") == OK)
	if not _popup_ui.is_connected("id_pressed", self, "_on_popup_item_selected"):
		assert(_popup_ui.connect("id_pressed", self, "_on_popup_item_selected") == OK)
	if not _dialogue.is_connected("update_view", self, "_on_update_view"):
		assert(_dialogue.connect("update_view", self, "_on_update_view") == OK)

func _on_scroll_offset_changed(ofs: Vector2) -> void:
	_dialogue.scroll_offset = ofs

func _on_node_selected(node: Node) -> void:
	_selected_node = node

func _node_connection_request(from, from_slot, to, to_slot):
	_dialogue.node_connection_request(from, from_slot, to, to_slot)

func _node_disconnection_request(from, from_slot, to, to_slot):
	_dialogue.node_disconnection_request(from, from_slot, to, to_slot)

func _on_mouse_popup_entered() -> void:
	_mouse_over_popup = true

func _on_mouse_popup_exited() -> void:
	_mouse_over_popup = false

func _on_update_view() -> void:
	_update_view()

func _on_gui_input(event: InputEvent) -> void:
	if _dialogue:
		if event is InputEventMouseButton:
			if event.get_button_index() == BUTTON_RIGHT and event.pressed:
				_mouse_position = event.position
				_show_popup()
			elif event.get_button_index() == BUTTON_LEFT and event.pressed:
				if _popup_ui.visible and not _mouse_over_popup:
					_popup_ui.hide()
		if event is InputEventKey and _selected_node:
			if event.scancode == KEY_DELETE and  event.pressed:
				_dialogue.del_node(_selected_node.node())

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
	if _dialogue.node_start() == null:
		_popup_ui.add_item("Start", 1)
		
func _build_popup_node_sentence() -> void:
	_popup_ui.add_item("Sentence", 2)

func _build_popup_node_end() -> void:
	if _dialogue.node_end() == null:
		_popup_ui.add_item("End", 3)

func _build_popup_delete_nodes() -> void:
	_popup_ui.add_item("Clear All", 4)

func _calc_popup_position() -> Vector2:
	var pos_x = _graph_ui.rect_global_position.x + _mouse_position.x
	var pos_y = _graph_ui.rect_global_position.y + _mouse_position.y
	return Vector2(pos_x, pos_y)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			if _popup_ui and _popup_ui.visible and not _mouse_over_popup:
				_popup_ui.hide()

func _on_popup_item_selected(id: int):
	var position = _calc_node_position()
	if id == 1:
		_dialogue.add_node_start(position)
	elif id == 2:
		_dialogue.add_node_sentence(position)
	elif id == 3:
		_dialogue.add_node_end(position)
	elif id == 4:
		_dialogue.del_nodes()

func _calc_node_position() -> Vector2:
	var offset_x = (_graph_ui.scroll_offset.x + _mouse_position.x) / _graph_ui.get_zoom()
	var offset_y = (_graph_ui.scroll_offset.y + _mouse_position.y) / _graph_ui.get_zoom()
	return Vector2(offset_x, offset_y)

func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	_graph_ui.clear_connections()
	for node in _graph_ui.get_children():
		if node is GraphNode:
			_graph_ui.remove_child(node)
			node.queue_free()

func _draw_view() -> void:
	for node in _dialogue.nodes:
		_draw_node_by_type(node)
	_draw_connections()
	_draw_connections_colors()

func _draw_node_by_type(node: DialogueNode) -> void:
	match node.type:
		DialogueNode.START:
			_draw_node_start(node)
		DialogueNode.SENTENCE:
			_draw_node_sentence(node)
		DialogueNode.END:
			_draw_node_end(node)

func _draw_node_start(node: DialogueNode) -> void:
	var node_start = NodeStart.instance()
	_draw_node(node, node_start)

func _draw_node_sentence(node: DialogueNode) -> void:
	var node_sentence = NodeSentence.instance()
	_draw_node(node, node_sentence)

func _draw_node_end(node: DialogueNode) -> void:
	var node_end = NodeEnd.instance()
	_draw_node(node, node_end)

func _draw_node(node: DialogueNode, node_ui) -> void:
	_graph_ui.add_child(node_ui)
	node_ui.set_data(node, _dialogue, _data)

func _draw_connections() -> void:
	for con in _dialogue.connections():
		if _graph_ui.has_node(con.from) and _graph_ui.has_node(con.to):
			_graph_ui.connect_node(con.from, con.from_port, con.to, con.to_port)

func _draw_connections_colors() -> void:
	_draw_connections_colors_default()
	_draw_connections_colors_path()

func _draw_connections_colors_default() -> void:
	for node in _dialogue.nodes:
		if _graph_ui.has_node(node.uuid):
			var node_ui = _graph_ui.get_node(node.uuid)
			if node_ui.has_method("update_slots_draw"):
				node_ui.update_slots_draw()


var _allready_drawed: Array
func _draw_connections_colors_path() -> void:
	_allready_drawed = []
	var node = _dialogue.node_start()
	if node:
		var node_start_ui = _graph_ui.get_node(node.uuid)
		node_start_ui.set_slot(0, false, 0, _data.SLOT_COLOR_DEFAULT, true, 0, _data.SLOT_COLOR_PATH)
		while(not(node.selected_sentence().node_uuid.empty()) and _not_allready_drawed(node.selected_sentence().node_uuid)):
			if _graph_ui.has_node(node.selected_sentence().node_uuid):
				var node_ui = _graph_ui.get_node(node.selected_sentence().node_uuid)
				node_ui.set_slot(0, true, 0, _data.SLOT_COLOR_PATH, false, 0, _data.SLOT_COLOR_DEFAULT)
				if node_ui.has_method("slot_index_of_selected_sentence"):
					var slot_index = node_ui.slot_index_of_selected_sentence()
					node_ui.set_slot(slot_index, false, 0, _data.SLOT_COLOR_DEFAULT, true, 0, _data.SLOT_COLOR_PATH)
			_allready_drawed.append(node.selected_sentence().node_uuid)
			node = _dialogue.node_by_uuid(node.selected_sentence().node_uuid)

func _not_allready_drawed(node_uuid) -> bool:
	return not _allready_drawed.has(node_uuid)
