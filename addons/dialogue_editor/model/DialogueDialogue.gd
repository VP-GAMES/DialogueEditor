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
	for node in nodes:
		node.set_editor(_editor)
	_undo_redo = _editor.get_undo_redo()

const UUID = preload("res://addons/dialogue_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****

# ***** IMPLEMENTATION *****
signal update_view()

func emit_signal_update_view() -> void:
	emit_signal("update_view")

export (String) var uuid
export (String) var name = ""
export (Vector2) var scroll_offset = Vector2.ZERO
export (Array) var nodes

# ***** ADD NODE *****
signal node_added(node)

func add_node_start(position: Vector2) -> void:
		var node = _create_node_start(position)
		if _undo_redo != null:
			_undo_redo.create_action("Add node start")
			_undo_redo.add_do_method(self, "_add_node", node)
			_undo_redo.add_undo_method(self, "_del_node", node)
			_undo_redo.commit_action()
		else:
			_add_node(node)

func _create_node_start(position: Vector2) -> DialogueNode:
	var node_start = _create_node(position)
	node_start.type = DialogueNode.START
	node_start.title = "Start"
	return node_start

func add_node_sentence(position: Vector2) -> void:
		var node = _create_node_sentence(position)
		if _undo_redo != null:
			_undo_redo.create_action("Add node sentence")
			_undo_redo.add_do_method(self, "_add_node", node)
			_undo_redo.add_undo_method(self, "_del_node", node)
			_undo_redo.commit_action()
		else:
			_add_node(node)

func _create_node_sentence(position: Vector2) -> DialogueNode:
	var node_sentence = _create_node(position)
	node_sentence.type = DialogueNode.SENTENCE
	node_sentence.title = "Sentence"
	return node_sentence

func add_node_end(position: Vector2) -> void:
		var node = _create_node_end(position)
		if _undo_redo != null:
			_undo_redo.create_action("Add node end")
			_undo_redo.add_do_method(self, "_add_node", node)
			_undo_redo.add_undo_method(self, "_del_node", node)
			_undo_redo.commit_action()
		else:
			_add_node(node)

func _create_node_end(position: Vector2) -> DialogueNode:
	var node_end = _create_node(position)
	node_end.type = DialogueNode.END
	node_end.title = "End"
	return node_end

func _create_node(position: Vector2) -> DialogueNode:
	var node = DialogueNode.new()
	node.set_editor(_editor)
	node.uuid = UUID.v4()
	node.position = position
	return node

func _add_node(node: DialogueNode, emitSignal = true, sentences_to_connect = []) -> void:
	nodes.append(node)
	for sentence in sentences_to_connect:
		sentence.node_uuid = node.uuid
	if emitSignal:
		emit_signal("node_added", node)
		emit_signal("update_view")

# ***** DEL NODE *****
signal node_removed(node)

func del_node(node: DialogueNode) -> void:
	var connected_to_sentences = sentences_has_connection(node)
	if _undo_redo != null:
		var index = nodes.find(node)
		_undo_redo.create_action("Del node")
		_undo_redo.add_do_method(self, "_del_node", node, connected_to_sentences)
		_undo_redo.add_undo_method(self, "_add_node", node, connected_to_sentences)
		_undo_redo.commit_action()
	else:
		_del_node(node)

func _del_node(node, emitSignal = true, sentences_to_disconnect = []) -> void:
	var index = nodes.find(node)
	if index > -1:
		for sentence in sentences_to_disconnect:
			sentence.node_uuid = ""
		nodes.remove(index)
		if emitSignal:
			emit_signal("node_removed", node)
			emit_signal("update_view")

# ***** DEL LIST OF NODES *****
signal nodes_removed(nodes)

func del_nodes(nodes_to_delete = null) -> void:
	if not nodes_to_delete:
		nodes_to_delete = []
		for node in nodes:
			nodes_to_delete.append(node)
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
	emit_signal("update_view")

# ***** ADD LIST OF NODES *****
signal nodes_added(nodes)

func _add_nodes(nodes_to_add: Array) -> void:
	for node in nodes_to_add:
		_add_node(node, false)
	emit_signal("nodes_added", nodes_to_add)
	emit_signal("update_view")

# ***** CONNECTION REQUEST *****
signal nodes_connected(from, to)

func node_connection_request(from, from_slot, to, to_slot):
	if from == to: 
		return
	var from_node = _node_by_uuid(from) as DialogueNode
	var to_node = _node_by_uuid(to) as DialogueNode
	if from_node.type == from_node.START and to_node.type == to_node.END: 
		return
	var sentence
	if from_node.type == from_node.START:
		sentence = sentence_has_connection(to_node)
	if _undo_redo != null:
		_undo_redo.create_action("Connect nodes")
		_undo_redo.add_do_method(self, "_node_connection_request", from_node, from_slot, to_node, to_slot, sentence)
		_undo_redo.add_undo_method(self, "_node_disconnection_request", from_node, from_slot, to_node, to_slot, sentence)
		_undo_redo.commit_action()
	else:
		_node_connection_request(from_node, from_slot, to_node, to_slot, sentence)

func _node_connection_request(from_node, from_slot, to_node, to_slot, sentence = null):
	if sentence:
		 sentence.node_uuid = ""
	from_node.sentences[from_slot].node_uuid = to_node.uuid
	emit_signal("nodes_connected", from_node, to_node)
	emit_signal("update_view")

# ***** DISCONNECTION REQUEST *****
signal nodes_disconnected(from, to)

func node_disconnection_request(from, from_slot, to, to_slot):
	var from_node = _node_by_uuid(from) as DialogueNode
	var to_node = _node_by_uuid(to) as DialogueNode
	if _undo_redo != null:
		_undo_redo.create_action("Disconnect nodes")
		_undo_redo.add_do_method(self, "_node_disconnection_request", from_node, from_slot, to_node, to_slot)
		_undo_redo.add_undo_method(self, "_node_connection_request", from_node, from_slot, to_node, to_slot)
		_undo_redo.commit_action()
	else:
		_node_disconnection_request(from_node, from_slot, to_node, to_slot)

func _node_disconnection_request(from_node, from_slot, to_node, to_slot, sentence = null):
	if sentence:
		 sentence.node_uuid = to_node.uuid
	from_node.sentences[from_slot].node_uuid = ""
	emit_signal("nodes_disconnected", from_node, to_node)
	emit_signal("update_view")

# ***** HELPER *****
func node_start() -> DialogueNode:
	for node_index in range(nodes.size()):
		var node = nodes[node_index] as DialogueNode
		if node.type == node.START:
			return node
	return null

func node_end() -> DialogueNode:
	for node_index in range(nodes.size()):
		var node = nodes[node_index] as DialogueNode
		if node.type == node.END:
			return node
	return null

func node_by_uuid(uuid: String) -> DialogueNode:
	return _node_by_uuid(uuid)

func _node_by_uuid(uuid: String) -> DialogueNode:
	for node in nodes:
		if node.uuid == uuid:
			return node
	return null

func connections() -> Array:
	var all_connections = []
	for node_index in range(nodes.size()):
		var node = nodes[node_index] as DialogueNode
		for sentence_index in range(node.sentences.size()):
			var sentence = node.sentences[sentence_index]
			if not sentence.node_uuid.empty():
				var connection = {
					"from": node.uuid, 
					"from_port": sentence_index,
					"to": sentence.node_uuid,
					"to_port": 0
				}
				all_connections.append(connection)
	return all_connections

func sentence_has_connection(to_node):
	for node_index in range(nodes.size()):
		var node = nodes[node_index] as DialogueNode
		for sentence_index in range(node.sentences.size()):
			var sentence = node.sentences[sentence_index]
			if not sentence.node_uuid.empty():
				if sentence.node_uuid == to_node.uuid:
					return sentence
	return null

func sentences_has_connection(to_node) -> Array:
	var sentences = []
	for node_index in range(nodes.size()):
		var node = nodes[node_index] as DialogueNode
		for sentence_index in range(node.sentences.size()):
			var sentence = node.sentences[sentence_index]
			if not sentence.node_uuid.empty():
				if sentence.node_uuid == to_node.uuid:
					sentences.append(sentence)
	return sentences

func events() -> PoolStringArray:
	var events = []
	for node in nodes:
		for sentence in node.sentences:
			if not sentence.event.empty():
				events.append(sentence.event)
	return events
