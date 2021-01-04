tool
extends WindowDialog

var _scene
var _data: DialogueData
# texte_events = [{"text": "", "event": null}]

onready var _actor_ui = $Margin/VBox/HBoxName/Actor as OptionButton
onready var _texture_ui = $Margin/VBox/TextureRect as TextureRect
onready var _buttons_add_ui = $Margin/VBox/VBoxText/HBoxAdd/Add as Button
onready var _clear_ui = $Margin/VBox/HBoxAction/Clear
onready var _close_ui = $Margin/VBox/HBoxAction/Close

func set_data(scene, data: DialogueData) -> void:
	_scene = scene
	_data = data
	_check_scene()
	_actor_ui_fill()
	_init_connections()
	_draw_view()

func _check_scene() -> void:
	if not _scene.has("preview"):
		_scene["preview"] = {}

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
	if not _clear_ui.is_connected("pressed", self, "_on_clear_pressed"):
		_clear_ui.connect("pressed", self, "_on_clear_pressed")

func _on_item_selected(index: int) -> void:
	if index > 0:
		_scene["preview"]["actor"] = _data.actors[index - 1]
	else:
		_scene["preview"].erase("actor")
	_draw_texture()

func _on_clear_pressed() -> void:
	_scene["preview"] = {}
	_draw_view()

func _draw_view() -> void:
	_draw_actor()
	_draw_texture()

func _draw_actor() -> void:
	if _scene.has("preview") and _scene["preview"].has("actor"):
		var index: = -1
		var actor = _scene["preview"]["actor"]
		for i in range(_actor_ui.get_item_count()):
			if actor == _actor_ui.get_item_metadata(i):
				print(i)
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
