tool
extends WindowDialog

var _scene
var _data: DialogueData

onready var _actor_ui = $Margin/VBox/HBoxName/Actor as OptionButton
onready var _texture_ui = $Margin/VBox/TextureRect as TextureRect
onready var _buttons_add_ui = $Margin/VBox/VBoxAdd/HBoxAdd/Add as Button
onready var _text_vbox_ui = $Margin/VBox/VBoxText as VBoxContainer
onready var _clear_ui = $Margin/VBox/HBoxAction/Clear as Button
onready var _close_ui = $Margin/VBox/HBoxAction/Close as Button

const DialogueScenePreviewSentenceDialogText = preload("res://addons/dialogue_editor/scenes/scenes/DialogueScenePreviewSentenceDialogText.tscn")

func set_data(scene, data: DialogueData) -> void:
	_scene = scene
	_data = data
	_check_scene()
	_actor_ui_fill()
	_init_connections()
	_draw_view()

func _check_scene() -> void:
	if not _scene.has("preview"):
		_scene["preview"] = { "texts": [""] }
	if not _scene["preview"].has("texts"):
		_scene["preview"]["texts"] = [""]
	if _scene["preview"]["texts"].empty():
		_scene["preview"]["texts"] = [""]

func _actor_ui_fill() -> void:
	_actor_ui.clear()
	_actor_ui.add_item("None")
	_actor_ui.set_item_metadata(0, DialogueActor.new())
	for index in range(_data.actors.size()):
		var actor = _data.actors[index]
		if not actor.resources.empty():
			var image = load(actor.resources[0].path)
			image = _data.resize_texture(image, Vector2(16, 16))
			_actor_ui.add_icon_item(image, actor.name, index)
		else:
			_actor_ui.add_item(actor.name, index + 1)
		_actor_ui.set_item_metadata(index + 1, actor)

func _init_connections() -> void:
	if not _actor_ui.is_connected("item_selected", self, "_on_item_selected"):
		_actor_ui.connect("item_selected", self, "_on_item_selected")
	if not _buttons_add_ui.is_connected("pressed", self, "_on_add_pressed"):
		_buttons_add_ui.connect("pressed", self, "_on_add_pressed")
	if not _clear_ui.is_connected("pressed", self, "_on_clear_pressed"):
		_clear_ui.connect("pressed", self, "_on_clear_pressed")
	if not _close_ui.is_connected("pressed", self, "_on_close_pressed"):
		_close_ui.connect("pressed", self, "_on_close_pressed")
	if not is_connected("hide", self, "_on_hide"):
		connect("hide", self, "_on_hide")

func _on_item_selected(index: int) -> void:
	if index > 0:
		_scene["preview"]["actor"] = _data.actors[index - 1]
	else:
		_scene["preview"].erase("actor")
	_draw_texture()

func _on_add_pressed() -> void:
	if _scene.has("preview") and _scene["preview"].has("texts"):
		_scene["preview"]["texts"].append("")
		_clear_and_draw_texts()

func _on_clear_pressed() -> void:
	_scene["preview"] = {}
	_draw_view()

func _on_close_pressed() -> void:
	hide()

func _on_hide() -> void:
	_data.emit_scene_preview_changed()

func _draw_view() -> void:
	_draw_actor()
	_draw_texture()
	_clear_and_draw_texts()

func _draw_actor() -> void:
	if _scene.has("preview") and _scene["preview"].has("actor"):
		var index: = -1
		var actor = _scene["preview"]["actor"]
		for i in range(_actor_ui.get_item_count()):
			if actor == _actor_ui.get_item_metadata(i):
				_actor_ui.select(i)
				return
		_actor_ui.select(0)

func _draw_texture() -> void:
	_set_default_texture()
	if _scene.has("preview") and _scene["preview"].has("actor"):
		var actor = _scene["preview"]["actor"]
		if not actor.resources.empty():
				var image = load(actor.resources[0].path)
				image = _data.resize_texture(image, Vector2(100, 100))
				_texture_ui.texture = image

func _set_default_texture() -> void:
	_texture_ui.texture = load("res://addons/dialogue_editor/icons/Image.png")

func _clear_and_draw_texts() -> void:
	_clear_texts()
	_draw_texts()

func _draw_texts() -> void:
	if _scene.has("preview") and _scene["preview"].has("texts"):
		for index in range(_scene["preview"]["texts"].size()):
			var text_ui = DialogueScenePreviewSentenceDialogText.instance()
			_text_vbox_ui.add_child(text_ui)
			text_ui.set_data(index, _scene)
			text_ui.connect("delete_action", self, "_on_delete_action")
		set_size(Vector2(rect_min_size.x, rect_min_size.y + 28 * _scene["preview"]["texts"].size()))

func _on_delete_action() -> void:
	_clear_and_draw_texts()

func _clear_texts() -> void:
	for text_ui in _text_vbox_ui.get_children():
		_text_vbox_ui.remove_child(text_ui)
		text_ui.queue_free()
