# Dialogue dialogue for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name DialogueDialogue, "res://addons/dialogue_editor/icons/Dialogue.png"

# ***** EDITOR_PLUGIN BOILERPLATE *****
var _editor: EditorPlugin
var _undo_redo: UndoRedo

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_undo_redo = _editor.get_undo_redo()

const UUID = preload("res://addons/dialogue_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****
signal node_added(node)
signal node_removed(node)
signal nodes_added(nodes)
signal nodes_removed(nodes)

export (String) var uuid
export (String) var name = ""
export (Vector2) var scroll_offset = Vector2.ZERO
export (Array) var nodes

func add_node_start(position: Vector2, sendSignal = true) -> void:
		var node = _create_node_start(position)
		if _undo_redo != null:
			_undo_redo.create_action("Add node start")
			_undo_redo.add_do_method(self, "_add_node", node)
			_undo_redo.add_undo_method(self, "_del_node", node)
			_undo_redo.commit_action()
		else:
			_add_node(node, sendSignal)

func _create_node_start(position: Vector2) -> DialogueNode:
	var node_start = DialogueNode.new()
	node_start.uuid = UUID.v4()
	node_start.type = DialogueNode.START
	node_start.name = "Start"
	node_start.position = position
	return node_start

func add_node_sentence(position: Vector2, sendSignal = true) -> void:
		var node = _create_node_sentence(position)
		if _undo_redo != null:
			_undo_redo.create_action("Add node sentence")
			_undo_redo.add_do_method(self, "_add_node", node)
			_undo_redo.add_undo_method(self, "_del_node", node)
			_undo_redo.commit_action()
		else:
			_add_node(node, sendSignal)

func _create_node_sentence(position: Vector2) -> DialogueNode:
	var node_sentence = DialogueNode.new()
	node_sentence.uuid = UUID.v4()
	node_sentence.type = DialogueNode.SENTENCE
	node_sentence.name = "Sentence"
	node_sentence.position = position
	return node_sentence

func add_node_end(position: Vector2, sendSignal = true) -> void:
		var node = _create_node_end(position)
		if _undo_redo != null:
			_undo_redo.create_action("Add node end")
			_undo_redo.add_do_method(self, "_add_node", node)
			_undo_redo.add_undo_method(self, "_del_node", node)
			_undo_redo.commit_action()
		else:
			_add_node(node, sendSignal)

func _create_node_end(position: Vector2) -> DialogueNode:
	var node_end = DialogueNode.new()
	node_end.uuid = UUID.v4()
	node_end.type = DialogueNode.END
	node_end.name = "End"
	node_end.position = position
	return node_end

func _add_node(node: DialogueNode, sendSignal = true) -> void:
	nodes.append(node)
	if sendSignal:
		emit_signal("node_added", node)

func del_node(node: DialogueNode) -> void:
	if _undo_redo != null:
		var index = nodes.find(node)
		_undo_redo.create_action("Del node")
		_undo_redo.add_do_method(self, "_del_node", node)
		_undo_redo.add_undo_method(self, "_add_node", node)
		_undo_redo.commit_action()
	else:
		_del_node(node)

func _del_node(node, sendSignal = true) -> void:
	var index = nodes.find(node)
	if index > -1:
		nodes.remove(index)
		if sendSignal:
			emit_signal("node_removed", node)

func del_nodes(nodes_to_delete = nodes) -> void:
	if _undo_redo != null:
		_undo_redo.create_action("Del all nodes")
		_undo_redo.add_do_method(self, "_del_nodes", nodes_to_delete)
		_undo_redo.add_undo_method(self, "_add_nodes", nodes_to_delete)
		_undo_redo.commit_action()
	else:
		_del_nodes(nodes_to_delete)

func _del_nodes(nodes_to_delete: Array) -> void:
	for node in nodes_to_delete:
		_del_node(node, false)
	emit_signal("nodes_removed", nodes_to_delete)
	
func _add_nodes(nodes_to_add: Array) -> void:
	for node in nodes_to_add:
		_add_node(node, false)
	emit_signal("nodes_added", nodes_to_add)
