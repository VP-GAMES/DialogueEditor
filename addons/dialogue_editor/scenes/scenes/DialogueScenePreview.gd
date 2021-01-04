# Dialogues scene preview for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _scene
var _loaded_scene
var _data: DialogueData

onready var _margin_ui = $Margin
onready var _preview_ui = $Margin/Preview

func set_data(data: DialogueData) -> void:
	_data = data
	_init_connections()

signal scene_added(scene)
signal scene_removed(scene)
signal scene_selection_changed

func _init_connections() -> void:
	if not _data.is_connected("scene_selection_changed", self, "_on_scene_need_update_view"):
		_data.connect("scene_selection_changed", self, "_on_scene_need_update_view")
	if not _data.is_connected("scene_added", self, "_on_scene_action"):
		_data.connect("scene_added", self, "_on_scene_action")
	if not _data.is_connected("scene_removed", self, "_on_scene_action"):
		_data.connect("scene_removed", self, "_on_scene_action")
	if not is_connected("resized", self, "_on_scene_need_update_view"):
		connect("resized", self, "_on_scene_need_update_view")
	if not _data.is_connected("scene_preview_changed", self, "_on_scene_need_update_view"):
		_data.connect("scene_preview_changed", self, "_on_scene_need_update_view")

func _on_scene_need_update_view():
	_update_view()

func _on_scene_action(scene) -> void:
	_update_view()

func _update_view() -> void:
	_clear_view()
	if _data:
		_scene = _data.selected_scene()
		if _scene:
			_draw_view()
			_draw_sentence()

func _draw_view() -> void:
	var LoadedScene = load(_scene.resource)
	_loaded_scene = LoadedScene.instance()
	_add_reference_rect()
	var display_size = _data.setting_display_size()
	var default_size = rect_size
	var scale = min(default_size.x / display_size.x, default_size.y / display_size.y)
	_loaded_scene.set_custom_minimum_size(display_size)
	if scale < 1:
		_loaded_scene.set_scale(Vector2(scale, scale))
	_preview_ui.add_child(_loaded_scene)

func _add_reference_rect() -> void:
	var ref_rect = ReferenceRect.new()
	ref_rect.border_color = Color.white
	ref_rect.editor_only = false
	ref_rect.anchor_right  = 1
	ref_rect.anchor_bottom = 1
	_loaded_scene.add_child(ref_rect)

func _clear_view() -> void:
	for child_ui in _preview_ui.get_children():
		_preview_ui.remove_child(child_ui)
		child_ui.queue_free()

func _draw_sentence() -> void:
	var sentence = _build_dialogue_sentence()
	if sentence and sentence.actor and not sentence.actor.resources.empty():
		sentence.texture_uuid = sentence.actor.resources[0].uuid
	_loaded_scene.sentence_set(sentence)

func _build_dialogue_sentence() -> DialogueSentence:
	var sentence = DialogueSentence.new()
	if _scene.has("preview"):
		if _scene["preview"].has("actor"):
			sentence.actor = _scene["preview"]["actor"]
	return sentence
