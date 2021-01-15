# Dialogue data for DialogueEditor : MIT License
# @author Vladimir Petrenko
extends Resource
class_name DialogueData

# ***** EDITOR_PLUGIN *****
var _editor: EditorPlugin
var _undo_redo: UndoRedo

func editor() -> EditorPlugin:
	return _editor

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	for actor in actors:
		actor.set_editor(_editor)
	for dialogue in dialogues:
		dialogue.set_editor(_editor)
	_undo_redo = _editor.get_undo_redo()

const UUID = preload("res://addons/dialogue_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****

# ***** ACTORS *****
signal actor_added(actor)
signal actor_removed(actor)
signal actor_selection_changed(actor)

export(Array) var actors = []
var _actor_selected: DialogueActor

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
	actor.uuid = UUID.v4()
	actor.name = _next_actor_name()
	actor.resources = []
	return actor

func _next_actor_name() -> String:
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
	emit_signal("actor_added", actor)
	select_actor(actor)

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
		emit_signal("actor_removed", actor)
		_actor_selected = null
		var actor_selected = selected_actor()
		select_actor(actor_selected)

func selected_actor() -> DialogueActor:
	if not _actor_selected and not actors.empty():
		_actor_selected = actors[0]
	return _actor_selected

func select_actor(actor: DialogueActor) -> void:
	_actor_selected = actor
	emit_signal("actor_selection_changed", _actor_selected)

# ***** SCENES *****
signal scene_added(scene)
signal scene_removed(scene)
signal scene_selection_changed(scene)
signal scene_preview_data_changed(scene)

export(Array) var scenes = [
	{"uuid": UUID.v4(), "resource": "res://addons/dialogue_editor/default/DialogueActorLeft.tscn"},
	{"uuid": UUID.v4(), "resource": "res://addons/dialogue_editor/default/DialogueActorCenter.tscn"},
	{"uuid": UUID.v4(), "resource": "res://addons/dialogue_editor/default/DialogueActorRight.tscn"}
]
var _scene_selected

func add_scene(resource: String, sendSignal = true) -> void:
	if _scene_exists(resource):
		printerr("Dialog resource: ", resource, " allready exists")
		return
	var scene = _create_scene(resource)
	if _undo_redo != null:
		_undo_redo.create_action("Add scene")
		_undo_redo.add_do_method(self, "_add_scene", scene)
		_undo_redo.add_undo_method(self, "_del_scene", scene)
		_undo_redo.commit_action()
	else:
		_add_scene(scene, sendSignal)

func _scene_exists(resource: String) -> bool:
	for scene in scenes:
		if scene.resource == resource:
			return true
	return false 

func _create_scene(resource):
	return {"uuid": UUID.v4(), "resource": resource}

func _add_scene(scene, sendSignal = true, position = scenes.size()) -> void:
	scenes.insert(position, scene)
	emit_signal("scene_added", scene)
	select_scene(scene)

func del_scene(scene) -> void:
	if _undo_redo != null:
		var index = scenes.find(scene)
		_undo_redo.create_action("Del scene")
		_undo_redo.add_do_method(self, "_del_scene", scene)
		_undo_redo.add_undo_method(self, "_add_scene", scene, false, index)
		_undo_redo.commit_action()
	else:
		_del_scene(scene)

func _del_scene(scene) -> void:
	var index = scenes.find(scene)
	if index > -1:
		scenes.remove(index)
		emit_signal("scene_removed", scene)
		_scene_selected = null
		var scene_selected = selected_scene()
		select_scene(scene_selected)

func selected_scene():
	if not _scene_selected and not scenes.empty():
		_scene_selected = scenes[0]
	return _scene_selected

func select_scene(scene) -> void:
	_scene_selected = scene
	emit_signal("scene_selection_changed", _scene_selected)

func emit_signal_scene_preview_data_changed(scene) -> void:
	emit_signal("scene_preview_data_changed", scene)

# ***** DIALOGUES *****
signal dialogue_added(dialogue)
signal dialogue_removed(dialogue)
signal dialogue_selection_changed(dialogue)
signal dialogue_view_selection_changed

export(Array) var dialogues = []

var _dialogue_selected: DialogueDialogue

func add_dialogue(sendSignal = true) -> void:
		var dialogue = _create_dialogue()
		if _undo_redo != null:
			_undo_redo.create_action("Add dialogue")
			_undo_redo.add_do_method(self, "_add_dialogue", dialogue)
			_undo_redo.add_undo_method(self, "_del_dialogue", dialogue)
			_undo_redo.commit_action()
		else:
			_add_dialogue(dialogue, sendSignal)

func _create_dialogue() -> DialogueDialogue:
	var dialogue = DialogueDialogue.new()
	dialogue.name = _next_dialogue_name()
	return dialogue

func _next_dialogue_name() -> String:
	var value = -9223372036854775807
	var dialogue_found = false
	for dialogue in dialogues:
		var name = dialogue.name
		if name.begins_with("Dialogue"):
			dialogue_found = true
			var behind = dialogue.name.substr(5)
			var regex = RegEx.new()
			regex.compile("^[0-9]+$")
			var result = regex.search(behind)
			if result:
				var new_value = int(behind)
				if  value < new_value:
					value = new_value
	var next_name = "Dialogue"
	if value != -9223372036854775807:
		next_name += str(value + 1)
	elif dialogue_found:
		next_name += "1"
	return next_name

func _add_dialogue(dialogue: DialogueDialogue, sendSignal = true, position = dialogues.size()) -> void:
	dialogues.insert(position, dialogue)
	emit_signal("dialogue_added", dialogue)
	select_dialogue(dialogue)

func del_dialogue(dialogue) -> void:
	if _undo_redo != null:
		var index = dialogues.find(dialogue)
		_undo_redo.create_action("Del dialogue")
		_undo_redo.add_do_method(self, "_del_dialogue", dialogue)
		_undo_redo.add_undo_method(self, "_add_dialogue", dialogue, false, index)
		_undo_redo.commit_action()
	else:
		_del_dialogue(dialogue)

func _del_dialogue(dialogue) -> void:
	var index = dialogues.find(dialogue)
	if index > -1:
		dialogues.remove(index)
		emit_signal("dialogue_removed", dialogue)
		_dialogue_selected = null
		var dialogue_selected = selected_dialogue()
		select_dialogue(dialogue_selected)

func selected_dialogue() -> DialogueDialogue:
	if not _dialogue_selected and not dialogues.empty():
		_dialogue_selected = dialogues[0]
	return _dialogue_selected

func select_dialogue(dialogue: DialogueDialogue) -> void:
	_dialogue_selected = dialogue
	emit_signal("dialogue_selection_changed", _dialogue_selected)

# ***** LOAD SAVE *****
func init_data() -> void:
	var file = File.new()
	if file.file_exists(PATH_TO_SAVE):
		var resource = ResourceLoader.load(PATH_TO_SAVE) as DialogueData
		if resource.actors and not resource.actors.empty():
			actors = resource.actors
		if resource.scenes and not resource.scenes.empty():
			scenes = resource.scenes
		if resource.dialogues and not resource.dialogues.empty():
			dialogues = resource.dialogues

func save() -> void:
	ResourceSaver.save(PATH_TO_SAVE, self)

# ***** EDITOR SETTINGS *****
const BACKGROUND_COLOR_SELECTED = Color("#868991")

const PATH_TO_SAVE = "res://addons/dialogue_editor/DialogueSave.res"
const SETTINGS_ACTORS_SPLIT_OFFSET = "dialogue_editor/actors_split_offset"
const SETTINGS_ACTORS_SPLIT_OFFSET_DEFAULT = 215
const SUPPORTED_ACTOR_RESOURCES = ["bmp", "jpg", "jpeg", "png", "svg", "svgz", "tres"]
const SETTINGS_SCENES_SPLIT_OFFSET = "dialogue_editor/scenes_split_offset"
const SETTINGS_SCENES_SPLIT_OFFSET_DEFAULT = 215
const SETTINGS_DIALOGUES_SPLIT_OFFSET = "dialogue_editor/dialogues_split_offset"
const SETTINGS_DIALOGUES_SPLIT_OFFSET_DEFAULT = 215
const SETTINGS_DIALOGUES_EDITOR_TYPE = "dialogue_editor/dialogues_editor_type"
const SETTINGS_DIALOGUES_EDITOR_TYPE_DEFAULT = "NODES"
const SETTINGS_DISPLAY_WIDTH = "display/window/size/width"
const SETTINGS_DISPLAY_HEIGHT = "display/window/size/height"

func setting_actors_split_offset() -> int:
	var offset = SETTINGS_ACTORS_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_ACTORS_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_ACTORS_SPLIT_OFFSET)
	return offset

func setting_actors_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_ACTORS_SPLIT_OFFSET, offset)

func setting_scenes_split_offset() -> int:
	var offset = SETTINGS_SCENES_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_SCENES_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_SCENES_SPLIT_OFFSET)
	return offset

func setting_scenes_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_SCENES_SPLIT_OFFSET, offset)

func setting_dialogues_split_offset() -> int:
	var offset = SETTINGS_DIALOGUES_SPLIT_OFFSET_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_DIALOGUES_SPLIT_OFFSET):
		offset = ProjectSettings.get_setting(SETTINGS_DIALOGUES_SPLIT_OFFSET)
	return offset

func setting_dialogues_split_offset_put(offset: int) -> void:
	ProjectSettings.set_setting(SETTINGS_DIALOGUES_SPLIT_OFFSET, offset)

func setting_dialogues_editor_type() -> String:
	var type = SETTINGS_DIALOGUES_EDITOR_TYPE_DEFAULT
	if ProjectSettings.has_setting(SETTINGS_DIALOGUES_EDITOR_TYPE):
		type = ProjectSettings.get_setting(SETTINGS_DIALOGUES_EDITOR_TYPE)
	return type

func setting_dialogues_editor_type_put(type: String) -> void:
	ProjectSettings.set_setting(SETTINGS_DIALOGUES_EDITOR_TYPE, type)
	emit_signal("dialogue_view_selection_changed")

func setting_display_size() -> Vector2:
	var width = ProjectSettings.get_setting(SETTINGS_DISPLAY_WIDTH)
	var height = ProjectSettings.get_setting(SETTINGS_DISPLAY_HEIGHT)
	return Vector2(width, height)

# ***** UTILS *****
func filename(value: String) -> String:
	var index = value.find_last("/")
	return value.substr(index + 1)

func filename_only(value: String) -> String:
	var first = value.find_last("/")
	var second = value.find_last(".")
	return value.substr(first + 1, second - first - 1)

func file_path(value: String) -> String:
	var index = value.find_last("/")
	return value.substr(0, index)

func file_extension(value: String):
	var index = value.find_last(".")
	if index == -1:
		return null
	return value.substr(index + 1)

func resource_exists(resource) -> bool:
	var file = File.new()
	return file.file_exists(resource.path)

func resize_texture(t: Texture, size: Vector2):
	var itex = t
	if itex:
		var texture = t.get_data()
		if size.x > 0 && size.y > 0:
			texture.resize(size.x, size.y)
		itex = ImageTexture.new()
		itex.create_from_image(texture)
	return itex
