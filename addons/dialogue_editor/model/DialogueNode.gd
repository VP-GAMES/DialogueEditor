# Dialogue node for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name DialogueNode, "res://addons/dialogue_editor/icons/Node.png"

signal actor_selection_changed(actor)
signal texture_selection_changed(texture_uuid)
signal view_selection_changed(texture_view)

# ***** EDITOR_PLUGIN BOILERPLATE *****
var _editor: EditorPlugin
var _undo_redo: UndoRedo

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_undo_redo = _editor.get_undo_redo()

const UUID = preload("res://addons/dialogue_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****

enum { START, END, SENTENCE }

export (String) var uuid
export (int) var type
export (String) var name
export (Vector2) var position
export (String) var scene = ""
export (Resource) var actor = DialogueEmpty.new() # DialogueActor
export (String) var texture_uuid = ""
export (bool) var texture_view = false
export (Array) var subnodes = [] # {"text": "", "event": null, "node": null}

func change_actor(new_actor: DialogueActor) -> void:
	if _undo_redo != null:
		var old_actor = new_actor
		var old_texture_uuid = texture_uuid
		var old_texture_view = texture_view
		_undo_redo.create_action("Node change actor")
		_undo_redo.add_do_method(self, "_change_actor", new_actor)
		_undo_redo.add_undo_method(self, "_change_actor", old_actor, old_texture_uuid, old_texture_view)
		_undo_redo.commit_action()
	else:
		_change_actor(new_actor)

func _change_actor(new_actor: DialogueActor, new_texture_uuid = "", new_texture_view = false) -> void:
	actor = new_actor
	texture_uuid = new_texture_uuid
	texture_view = new_texture_view
	emit_signal("actor_selection_changed", actor)

func change_texture_uuid(new_texture_uuid) -> void:
	if _undo_redo != null:
		var old_texture_uuid = texture_uuid
		var old_texture_view = texture_view
		_undo_redo.create_action("Node change texture_uuid")
		_undo_redo.add_do_method(self, "_change_texture_uuid", new_texture_uuid)
		_undo_redo.add_undo_method(self, "_change_texture_uuid", old_texture_uuid, old_texture_view)
		_undo_redo.commit_action()
	else:
		_change_texture_uuid(new_texture_uuid)

func _change_texture_uuid(new_texture_uuid: String, new_texture_view = texture_view) -> void:
	texture_uuid = new_texture_uuid
	texture_view = new_texture_view
	if texture_uuid.empty():
		texture_view = false
	emit_signal("texture_selection_changed", texture_uuid)

func change_texture_view(new_texture_view) -> void:
	if _undo_redo != null:
		var old_texture_view = texture_view
		_undo_redo.create_action("Node change texture_view")
		_undo_redo.add_do_method(self, "_change_texture_view", new_texture_view)
		_undo_redo.add_undo_method(self, "_change_texture_view", old_texture_view)
		_undo_redo.commit_action()
	else:
		_change_texture_view(new_texture_view)

func _change_texture_view(new_texture_view) -> void:
	texture_view = new_texture_view
	if not texture_uuid:
		texture_view = false
	emit_signal("view_selection_changed", texture_view)

func actor_empty_object() -> bool:
	return actor is DialogueEmpty
