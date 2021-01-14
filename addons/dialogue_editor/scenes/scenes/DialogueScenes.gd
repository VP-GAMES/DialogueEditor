# Dialogue scenes UI for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends Panel

var _data: DialogueData

onready var _add_ui = $Margin/VBox/HBox/Add
onready var _scenes_ui = $Margin/VBox/Scroll/Scenes

const DialogueSceneResourceFile = preload("res://addons/dialogue_editor/scenes/scenes/DialogueSceneResourceFile.tscn")
const DialogueSceneUI = preload("res://addons/dialogue_editor/scenes/scenes/DialogueSceneUI.tscn")

func set_data(data: DialogueData) -> void:
	_data = data
	_scenes_ui.set_data(data)
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _add_ui.is_connected("pressed", self, "_add_pressed"):
		assert(_add_ui.connect("pressed", self, "_add_pressed") == OK)
	if not _data.is_connected("scene_added", self, "_on_scene_added"):
		assert(_data.connect("scene_added", self, "_on_scene_added") == OK)
	if not _data.is_connected("scene_removed", self, "_on_scene_removed"):
		assert(_data.connect("scene_removed", self, "_on_scene_removed") == OK)

func _on_scene_added(scene) -> void:
	_update_view()

func _on_scene_removed(scene) -> void:
	_update_view()

func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	for scene_ui in _scenes_ui.get_children():
		_scenes_ui.remove_child(scene_ui)
		scene_ui.queue_free()

func _draw_view() -> void:
	for scene in _data.scenes:
		_draw_scene(scene)

func _draw_scene(scene) -> void:
	var scene_ui = DialogueSceneUI.instance()
	_scenes_ui.add_child(scene_ui)
	scene_ui.set_data(scene, _data)

func _add_pressed() -> void:
	var file_dialog = DialogueSceneResourceFile.instance()
	file_dialog.add_filter("*.tscn")
	var root = get_tree().get_root()
	root.add_child(file_dialog)
	assert(file_dialog.connect("file_selected", self, "_add_scene_resource") == OK)
	assert(file_dialog.connect("popup_hide", self, "_on_popup_hide", [root, file_dialog]) == OK)
	file_dialog.popup_centered()

func _add_scene_resource(resource_value) -> void:
	_data.add_scene(resource_value)

func _on_popup_hide(root, dialog) -> void:
	root.remove_child(dialog)
	dialog.queue_free()
