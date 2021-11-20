# Dialogue actor for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name DialogueActor, "res://addons/dialogue_editor/icons/Actor.png"

# ***** EDITOR_PLUGIN BOILERPLATE *****
var _editor
var _undo_redo

func set_editor(editor) -> void:
	_editor = editor
	_undo_redo = _editor.get_undo_redo()

const UUID = preload("res://addons/dialogue_editor/uuid/uuid.gd")
# ***** EDITOR_PLUGIN_END *****

signal name_changed(name)
signal uiname_changed(uiname)
signal resource_added(resource)
signal resource_removed(resource)
signal resource_name_changed(resource)
signal resource_path_changed(resource)
signal resource_selection_changed(resource)

export (String) var uuid
export (String) var name = ""
export (String) var uiname = ""
export (Array) var resources = [] # List of Resources
var _resource_selected = null

func change_name(new_name: String):
	name = new_name
	emit_signal("changed")
	emit_signal("name_changed")

func change_uiname(new_uiname: String):
	uiname = new_uiname
	emit_signal("changed")
	emit_signal("uiname_changed")

func add_resource() -> void:
	var resource = _create_resource()
	if _undo_redo != null:
		_undo_redo.create_action("Add actor resource")
		_undo_redo.add_do_method(self, "_add_resource", resource)
		_undo_redo.add_undo_method(self, "_del_resource", resource)
		_undo_redo.commit_action()
	else:
		_add_resource(resource)

func _create_resource():
	return {"uuid": UUID.v4(), "name": "", "path": ""}

func _add_resource(resource, position = resources.size()) -> void:
	resources.insert(position, resource)
	emit_signal("changed")
	emit_signal("resource_added", resource)
	select_resource(resource)

func del_resource(resource) -> void:
	if _undo_redo != null:
		var index = resources.find(resource)
		_undo_redo.create_action("Del actor resource")
		_undo_redo.add_do_method(self, "_del_resource", resource)
		_undo_redo.add_undo_method(self, "_add_resource", resource, index)
		_undo_redo.commit_action()
	else:
		_del_resource(resource)

func _del_resource(resource) -> void:
	var index = resources.find(resource)
	if index > -1:
		resources.remove(index)
		emit_signal("changed")
		emit_signal("resource_removed", resource)
		var resource_selected = selected_resource()
		select_resource(resource_selected)

func change_resource_name(resource: Dictionary, name: String) -> void:
	var old_name = resource.name
	if _undo_redo != null:
		_undo_redo.create_action("Change actor resource name")
		_undo_redo.add_do_method(self, "_change_resource_name", resource, name, true)
		_undo_redo.add_undo_method(self, "_change_resource_name", resource, old_name)
		_undo_redo.commit_action()
	else:
		_change_resource_name(resource, name)

func _change_resource_name(resource: Dictionary, name: String, sendSignal = false) -> void:
	resource.name = name
	emit_signal("changed")
	if sendSignal:
		emit_signal("resource_name_changed", resource)

func change_resource_path(resource: Dictionary, path: String) -> void:
	var old_path = resource.path
	var old_name = resource.name
	var new_name = resource.name
	if resource.name.empty():
		new_name = _filename_only(path)
	if _undo_redo != null:
		_undo_redo.create_action("Change actor resource path")
		_undo_redo.add_do_method(self, "_resource_path_change", resource, path, new_name)
		_undo_redo.add_undo_method(self, "_resource_path_change", resource, old_path, old_name)
		_undo_redo.commit_action()
	else:
		_resource_path_change(resource, path, new_name)

func _resource_path_change(resource: Dictionary, path: String, name: String) -> void:
	resource.path = path
	var name_changed = resource.name != name
	if name_changed:
		resource.name = name
	resource.name = name
	emit_signal("changed")
	emit_signal("resource_path_changed", resource)
	if name_changed:
		emit_signal("resource_name_changed", resource)

func selected_resource():
	if not _resource_selected and not resources.empty():
		_resource_selected = resources[0]
	return _resource_selected

func select_resource(resource) -> void:
	emit_signal("resource_selection_changed", resource)

func default_uuid() -> String:
	var uuid = null
	if not resources.empty() and resources.size() >= 1:
		uuid = resources[0].uuid
	return uuid

func resource_by_uuid(uuid = null, default_texture = true) -> Resource:
	var texture = null
	if not resources.empty():
		if resources.size() == 1 and default_texture:
			texture = load(resources[0].path)
		elif uuid and resources.size() >= 1:
			for res in resources:
				if res.uuid == uuid:
					texture = load(res.path)
					break
	return texture

func _filename_only(value: String) -> String:
	var first = value.find_last("/")
	var second = value.find_last(".")
	return value.substr(first + 1, second - first - 1)
