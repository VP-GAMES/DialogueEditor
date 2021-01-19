# Dialogue node for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name DialogueNode, "res://addons/dialogue_editor/icons/Node.png"

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
export (Array) var sentences = [{"uuid": UUID.v4(), "text": "", "event_visible": false, "event": "", "node": DialogueEmpty.new()}]
export (Dictionary) var sentence_selected = sentences[0]

# ***** SCENES *****
signal scene_selection_changed(scene)

func change_scene(new_scene = "") -> void:
	if _undo_redo != null:
		var old_scene = new_scene
		var old_actor = actor
		var old_texture_uuid = texture_uuid
		var old_texture_view = texture_view
		_undo_redo.create_action("Node change scene")
		_undo_redo.add_do_method(self, "_change_scene", new_scene, actor)
		_undo_redo.add_undo_method(self, "_change_scene", old_scene, old_actor, old_texture_uuid, old_texture_view)
		_undo_redo.commit_action()
	else:
		_change_scene(new_scene, actor)

func _change_scene(new_scene: String, new_actor: Resource, new_texture_uuid = "", new_texture_view = false) -> void:
	scene = new_scene
	if scene.empty():
		new_actor = DialogueEmpty.new()
		new_texture_uuid = ""
		new_texture_view = false
	actor = new_actor
	texture_uuid = new_texture_uuid
	texture_view = new_texture_view
	emit_signal("scene_selection_changed", scene)

# ***** ACTORS *****
signal actor_selection_changed(actor)

func change_actor(new_actor = Resource.new()) -> void:
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

func is_actor_empty_object() -> bool:
	return actor is DialogueEmpty

# ***** TEXTURE_UUID *****
signal texture_selection_changed(texture_uuid)

func change_texture_uuid(new_texture_uuid = "") -> void:
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

# ***** TEXTURE_VIEW *****
signal view_selection_changed(texture_view)

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

# ***** SENTENCES *****
signal sentence_added(sentence)
signal sentence_removed(sentence)
signal sentence_selection_changed(sentence)
signal sentence_event_visibility_changed(sentence)

func add_sentence(sendSignal = true) -> void:
		var sentence = _create_sentence()
		if _undo_redo != null:
			_undo_redo.create_action("Add sentence")
			_undo_redo.add_do_method(self, "_add_sentence", sentence)
			_undo_redo.add_undo_method(self, "_del_sentence", sentence)
			_undo_redo.commit_action()
		else:
			_add_sentence(sentence, sendSignal)

func _create_sentence() -> Dictionary:
	var sentence = {}
	sentence.uuid = UUID.v4()
	sentence.text = ""
	sentence.event = ""
	sentence.node = DialogueEmpty.new()
	return sentence

func _add_sentence(sentence: Dictionary, sendSignal = true, position = sentences.size()) -> void:
	sentences.insert(position, sentence)
	emit_signal("sentence_added", sentence)

func del_sentence(sentence) -> void:
	if _undo_redo != null:
		var index = sentences.find(sentence)
		_undo_redo.create_action("Del sentence")
		_undo_redo.add_do_method(self, "_del_sentence", sentence)
		_undo_redo.add_undo_method(self, "_add_sentence", sentence, false, index)
		_undo_redo.commit_action()
	else:
		_del_sentence(sentence)

func _del_sentence(sentence) -> void:
	var index = sentences.find(sentence)
	if index > -1:
		sentences.remove(index)
		emit_signal("sentence_removed", sentence)
		var sentence_selected = selected_sentence()
		_select_sentence(sentence_selected)

func select_sentence_event_visibility(sentence: Dictionary, visibility: bool) -> void:
	if _undo_redo != null:
		var old_sentence = sentence
		var old_visibility = visibility
		_undo_redo.create_action("Select sentence event visibility")
		_undo_redo.add_do_method(self, "_select_sentence_event_visibility", sentence, visibility)
		_undo_redo.add_undo_method(self, "_select_sentence_event_visibility", old_sentence, old_visibility)
		_undo_redo.commit_action()
	else:
		_select_sentence_event_visibility(sentence, visibility)

func _select_sentence_event_visibility(sentence: Dictionary, visibility: bool) -> void:
	sentence.event_visible = visibility
	emit_signal("sentence_event_visibility_changed", sentence)

func selected_sentence() -> Dictionary:
	var selected_sentence_exists = sentences.has(sentence_selected)
	if not selected_sentence_exists and not sentences.empty():
		sentence_selected = sentences[0]
	return sentence_selected

func select_sentence(sentence: Dictionary, sendSignal = true) -> void:
	if _undo_redo != null:
		var old_sentence = sentence_selected
		_undo_redo.create_action("Select sentence")
		_undo_redo.add_do_method(self, "_select_sentence", sentence)
		_undo_redo.add_undo_method(self, "_select_sentence", old_sentence)
		_undo_redo.commit_action()
	else:
		_select_sentence(sentence)

func _select_sentence(sentence: Dictionary, sendSignal = true) -> void:
	sentence_selected = sentence
	if sendSignal:
		emit_signal("sentence_selection_changed", sentence_selected)
