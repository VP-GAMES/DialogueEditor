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
		_init_connections()
		_update_view()

func _init_connections() -> void:
	if not _dialogue.is_connected("node_added", self, "_on_node_added"):
		assert(_dialogue.connect("node_added", self, "_on_node_added") == OK)
	if not _dialogue.is_connected("nodes_added", self, "_on_nodes_added"):
		assert(_dialogue.connect("nodes_added", self, "_on_nodes_added") == OK)
	if not _dialogue.is_connected("node_removed", self, "_on_node_removed"):
		assert(_dialogue.connect("node_removed", self, "_on_node_removed") == OK)
	if not _dialogue.is_connected("nodes_removed", self, "_on_nodes_removed"):
		assert(_dialogue.connect("nodes_removed", self, "_on_nodes_removed") == OK)
	if not _popup_ui.is_connected("mouse_entered", self, "_on_mouse_popup_entered"):
		assert(_popup_ui.connect("mouse_entered", self, "_on_mouse_popup_entered") == OK)
	if not _popup_ui.is_connected("mouse_exited", self, "_on_mouse_popup_exited"):
		assert(_popup_ui.connect("mouse_exited", self, "_on_mouse_popup_exited") == OK)
	if not _graph_ui.is_connected("scroll_offset_changed", self, "_on_scroll_offset_changed"):
		assert(_graph_ui.connect("scroll_offset_changed", self, "_on_scroll_offset_changed") == OK)
	if not _graph_ui.is_connected("node_selected", self, "_on_node_selected"):
		assert(_graph_ui.connect("node_selected", self, "_on_node_selected") == OK)
	if not _graph_ui.is_connected("gui_input", self, "_on_gui_input"):
		assert(_graph_ui.connect("gui_input", self, "_on_gui_input") == OK)
	if not _popup_ui.is_connected("id_pressed", self, "_on_popup_item_selected"):
		assert(_popup_ui.connect("id_pressed", self, "_on_popup_item_selected") == OK)

func _on_node_added(node: DialogueNode) -> void:
	_update_view()

func _on_nodes_added(nodes: Array) -> void:
	_update_view()

func _on_node_removed(node: DialogueNode) -> void:
	_update_view()

func _on_nodes_removed(nodes: Array) -> void:
	_update_view()

func _on_mouse_popup_entered() -> void:
	_mouse_over_popup = true

func _on_mouse_popup_exited() -> void:
	_mouse_over_popup = false

func _on_scroll_offset_changed(ofs: Vector2) -> void:
	_dialogue.scroll_offset = ofs

func _on_node_selected(node: Node) -> void:
	_selected_node = node

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_LEFT and event.pressed:
			if _popup_ui.visible and not _mouse_over_popup:
				_popup_ui.hide()

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
				_dialogue.del_node(_selected_node.nodedata())

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
	_graph_ui.scroll_offset = _dialogue.scroll_offset
	for node in _dialogue.nodes:
		_draw_node_by_type(node)

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
	node_start.set_nodedata(node)
	_graph_ui.add_child(node_start)

func _draw_node_sentence(node: DialogueNode) -> void:
	var node_sentence = NodeSentence.instance()
	node_sentence.set_nodedata(node)
	_graph_ui.add_child(node_sentence)

func _draw_node_end(node: DialogueNode) -> void:
	var node_end = NodeEnd.instance()
	node_end.set_nodedata(node)
	_graph_ui.add_child(node_end)
