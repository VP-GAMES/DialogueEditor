# Dialogues scene preview for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _scene
var _loaded_scene
var _data: DialogueData

onready var _margin_ui = $Scroll/Margin
onready var _reference_ui = $Scroll/Margin/Reference

func set_data(data: DialogueData) -> void:
	_data = data
	_init_reference_ui()
	_init_connections()
	_update_view()

signal scene_added(scene)
signal scene_removed(scene)
signal scene_selection_changed

func _init_reference_ui() -> void:
	_reference_ui.set_custom_minimum_size(_data.setting_display_size())
	_reference_ui.rect_size = _data.setting_display_size()
	# Scale to vieport size .set_scale(Vector(1, 1))

func _init_connections() -> void:
	if not _data.is_connected("scene_selection_changed", self, "_on_scene_selection"):
		_data.connect("scene_selection_changed", self, "_on_scene_selection")
	if not _data.is_connected("scene_added", self, "_on_scene_action"):
		_data.connect("scene_added", self, "_on_scene_action")
	if not _data.is_connected("scene_removed", self, "_on_scene_action"):
		_data.connect("scene_removed", self, "_on_scene_action")

func _on_scene_selection() -> void:
	_update_view()

func _on_scene_action(scene) -> void:
	_update_view()

func _update_view() -> void:
	_scene = _data.selected_scene()
	if _scene:
		_clear_view()
		_draw_view()
	else:
		_clear_view()

func _draw_view() -> void:
	var LoadedScene = load(_scene.resource)
	_loaded_scene = LoadedScene.instance()
	_reference_ui.add_child(_loaded_scene)

func _clear_view() -> void:
	for child_ui in _reference_ui.get_children():
		_reference_ui.remove_child(child_ui)
		child_ui.queue_free()
