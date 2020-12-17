# Dialogue data for DialogueEditor : MIT License
# @author Vladimir Petrenko
extends Resource
class_name DialogueData

signal actor_added(actor)
signal actor_removed(actor)
signal selected_actor_changed

var _editor: EditorPlugin
var _undo_redo: UndoRedo

var _actor_selected: DialogueActor

export(Array) var actors

const PATH_TO_SAVE = "res://addons/dialogue_editor/DialogueSave.res"
const SETTINGS_ACTORS_SPLIT_OFFSET = "dialogue_editor/actors_split_offset"

func selected_actor() -> DialogueActor:
	if not _actor_selected and not actors.empty():
		_actor_selected = actors[0]
	return _actor_selected

func selected_actor_set(actor: DialogueActor) -> void:
	_actor_selected = actor
	emit_signal("selected_actor_changed")

func add_actor(sendSignal = true) -> void:
		var actor = _create_actor()
		if _undo_redo != null:
			_undo_redo.create_action("Add actor")
			_undo_redo.add_do_method(self, "_add_actor", actor)
			_undo_redo.add_undo_method(self, "_del_actor", actor)
			_undo_redo.commit_action()
		else:
			_add_actor(actor, sendSignal)

func _create_actor() -> DialogueActor:
	var actor = DialogueActor.new()
	actor.name = _next_autor_name()
	return actor

func _next_autor_name() -> String:
	var value = -9223372036854775807
	var actor_found = false
	for actor in actors:
		var name = actor.name
		if name.begins_with("Actor"):
			actor_found = true
			var behind = actor.name.substr(5)
			var regex = RegEx.new()
			regex.compile("^[0-9]+$")
			var result = regex.search(behind)
			if result:
				var new_value = int(behind)
				if  value < new_value:
					value = new_value
	var next_name = "Actor"
	if value != -9223372036854775807:
		next_name += str(value + 1)
	elif actor_found:
		next_name += "1"
	return next_name

func _add_actor(actor: DialogueActor, sendSignal = true, position = actors.size()) -> void:
	actors.insert(position, actor)
	_actor_selected = actor
	emit_signal("actor_added", actor)

func del_actor(actor) -> void:
	if _undo_redo != null:
		var index = actors.find(actor)
		_undo_redo.create_action("Del actor")
		_undo_redo.add_do_method(self, "_del_actor", actor)
		_undo_redo.add_undo_method(self, "_add_actor", actor, false, index)
		_undo_redo.commit_action()
	else:
		_del_actor(actor)

func _del_actor(actor) -> void:
	var index = actors.find(actor)
	if index > -1:
		actors.remove(index)
		_actor_selected = null
		_actor_selected = selected_actor()
		emit_signal("actor_removed", actor)

func init_data() -> void:
	pass

func save() -> void:
	pass

# ***** EDITOR SETTINGS *****
func editor() -> EditorPlugin:
	return _editor

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	if _editor:
		_undo_redo = _editor.get_undo_redo()

func undo_redo() -> UndoRedo:
	return _undo_redo

func setting_actors_split_offset() -> int:
	var offset = 215
	if ProjectSettings.has_setting(SETTINGS_ACTORS_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_ACTORS_SPLIT_OFFSET)
	return offset

func setting_actors_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_ACTORS_SPLIT_OFFSET, offset)
