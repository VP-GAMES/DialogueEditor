# Dialogue data for DialogueEditor : MIT License
# @author Vladimir Petrenko
extends Resource
class_name DialogueData

signal data_changed

var _editor: EditorPlugin
var _undo_redo: UndoRedo

export(Array) var actors

const PATH_TO_SAVE = "res://addons/dialogue_editor/DialogueSave.res"
const SETTINGS_ACTORS_SPLIT_OFFSET = "dialogue_editor/actors_split_offset"

func add_actor(sendSignal = true) -> void:
		var actor = DialogueActor.new()
		if _undo_redo != null:
			_undo_redo.create_action("Add actor")
			_undo_redo.add_do_method(self, "_add_actor")
			_undo_redo.add_undo_method(self, "_del_actor", actor)
			_undo_redo.commit_action()
		else:
			_add_actor(actor, sendSignal)

func _add_actor(actor: DialogueActor, sendSignal: bool) -> void:
	pass

func del_actor(actor) -> void:
	if _undo_redo != null:
		_undo_redo.create_action("Del actor")
		_undo_redo.add_do_method(self, "_del_actor", actor)
		_undo_redo.add_undo_method(self, "_add_actor", actor)
		_undo_redo.commit_action()
	else:
		_del_actor(actor)

func _del_actor(actor) -> void:
	pass

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
	var offset = 350
	if ProjectSettings.has_setting(SETTINGS_ACTORS_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_ACTORS_SPLIT_OFFSET)
	return offset

func setting_actors_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_ACTORS_SPLIT_OFFSET, offset)
