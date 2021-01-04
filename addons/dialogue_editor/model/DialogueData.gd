# Dialogue data for DialogueEditor : MIT License
# @author Vladimir Petrenko
extends Resource
class_name DialogueData

signal actor_added(actor)
signal actor_removed(actor)
signal actor_selection_changed

signal actor_resource_added(resource)
signal actor_resource_removed(resource)
signal actor_resource_selection_changed(resource)
signal actor_resource_path_changed(resource)

signal scene_added(scene)
signal scene_removed(scene)
signal scene_selection_changed

signal scene_resource_selection_changed(resource)
signal scene_resource_path_changed(resource)

signal scene_preview_changed

var _editor: EditorPlugin
var _undo_redo: UndoRedo

export(Array) var actors = []
var _actor_selected: DialogueActor

export(Array) var scenes = [
	{"uuid": uuid_gen.v4(), "resource": "res://addons/dialogue_editor/default/DialogueActorLeft.tscn"},
	{"uuid": uuid_gen.v4(), "resource": "res://addons/dialogue_editor/default/DialogueActorRight.tscn"}
]
var _scene_selected

const uuid_gen = preload("res://addons/dialogue_editor/uuid/uuid.gd")

const PATH_TO_SAVE = "res://addons/dialogue_editor/DialogueSave.res"
const SETTINGS_ACTORS_SPLIT_OFFSET = "dialogue_editor/actors_split_offset"
const SETTINGS_ACTORS_SPLIT_OFFSET_DEFAULT = 215
const SUPPORTED_ACTOR_RESOURCES = ["bmp", "jpg", "jpeg", "png", "svg", "svgz", "tres"]
const SETTINGS_SCENES_SPLIT_OFFSET = "dialogue_editor/scenes_split_offset"
const SETTINGS_SCENES_SPLIT_OFFSET_DEFAULT = 215
const SETTINGS_DISPLAY_WIDTH = "display/window/size/width"
const SETTINGS_DISPLAY_HEIGHT = "display/window/size/height"

# ***** ACTORS *****
func selected_actor() -> DialogueActor:
	if not _actor_selected and not actors.empty():
		_actor_selected = actors[0]
	return _actor_selected

func selected_actor_set(actor: DialogueActor) -> void:
	_actor_selected = actor
	emit_signal("actor_selection_changed")

func add_actor(sendSignal = true) -> void:
		var actor = _create_actor()
		print(actor.resources)
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
	actor.resources = []
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
	emit_signal("actor_added", actor)
	selected_actor_set(actor)

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
		selected_actor_set(actor_selected)

func init_data() -> void:
	var file = File.new()
	if file.file_exists(PATH_TO_SAVE):
		var resource = ResourceLoader.load(PATH_TO_SAVE) as DialogueData
		if resource.actors and not resource.actors.empty():
			actors = resource.actors
		if resource.scenes and not resource.scenes.empty():
			scenes = resource.scenes

func save() -> void:
	ResourceSaver.save(PATH_TO_SAVE, self)

func add_actor_resource() -> void:
	var resource = _create_actor_resource()
	if _undo_redo != null:
		_undo_redo.create_action("Add actor resource")
		_undo_redo.add_do_method(self, "_add_actor_resource", resource)
		_undo_redo.add_undo_method(self, "_del_actor_resource", resource)
		_undo_redo.commit_action()
	else:
		_add_actor_resource(resource)

func _create_actor_resource():
	return {"uuid": uuid_gen.v4(), "name": "", "path": ""}

func _add_actor_resource(resource, position = _actor_selected.resources.size()) -> void:
	_actor_selected.resources.insert(position, resource)
	emit_signal("actor_resource_added", resource)

func del_actor_resource(resource) -> void:
	if _undo_redo != null:
		var index = _actor_selected.resources.find(resource)
		_undo_redo.create_action("Del actor resource")
		_undo_redo.add_do_method(self, "_del_actor_resource", resource)
		_undo_redo.add_undo_method(self, "_add_actor_resource", resource, index)
		_undo_redo.commit_action()
	else:
		_del_actor_resource(resource)

func _del_actor_resource(resource) -> void:
	var index = _actor_selected.resources.find(resource)
	if index > -1:
		_actor_selected.resources.remove(index)
		emit_signal("actor_resource_removed", resource)

func actor_resource_name_change(resource: Dictionary, name: String) -> void:
	var old_name = resource.name
	if _undo_redo != null:
		_undo_redo.create_action("Change actor resource name")
		_undo_redo.add_do_method(self, "_actor_resource_name_change", resource, name)
		_undo_redo.add_undo_method(self, "_actor_resource_name_change", resource, old_name)
		_undo_redo.commit_action()
	else:
		_actor_resource_name_change(resource, name)

func _actor_resource_name_change(resource: Dictionary, name: String) -> void:
	resource.name = name

func actor_resource_path_change(resource: Dictionary, path: String) -> void:
	var old_path = resource.path
	if _undo_redo != null:
		_undo_redo.create_action("Change actor resource path")
		_undo_redo.add_do_method(self, "_actor_resource_path_change", resource, path)
		_undo_redo.add_undo_method(self, "_actor_resource_path_change", resource, old_path)
		_undo_redo.commit_action()
	else:
		_actor_resource_path_change(resource, path)

func _actor_resource_path_change(resource: Dictionary, path: String) -> void:
	resource.path = path
	emit_signal("actor_resource_path_changed", resource)

func actor_resource_selection(resource) -> void:
	emit_signal("actor_resource_selection_changed", resource)

# ***** SCENES *****
func selected_scene():
	if not _scene_selected and not scenes.empty():
		_scene_selected = scenes[0]
	return _scene_selected

func selected_scene_set(scene) -> void:
	_scene_selected = scene
	emit_signal("scene_selection_changed")

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
	return {"uuid": uuid_gen.v4(), "resource": resource}

func _add_scene(scene, sendSignal = true, position = scenes.size()) -> void:
	scenes.insert(position, scene)
	emit_signal("scene_added", scene)
	selected_scene_set(scene)

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
		selected_scene_set(scene_selected)

func emit_scene_preview_changed() -> void:
	emit_signal("scene_preview_changed")

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
	var image = t.get_data()
	if size.x > 0 && size.y > 0:
		image.resize(size.x, size.y)
	var itex = ImageTexture.new()
	itex.create_from_image(image)
	return itex
