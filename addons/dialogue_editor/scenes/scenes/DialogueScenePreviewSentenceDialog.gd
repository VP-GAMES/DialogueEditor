tool
extends WindowDialog

var _data: DialogueData

onready var _actor_ui = $Margin/VBox/HBoxName/Actor
onready var _texture_ui = $Margin/VBox/Texture
onready var _type_text_ui = $Margin/VBox/HBoxType/TypeText
onready var _type_buttons_ui = $Margin/VBox/HBoxType/TypeButtons
onready var _text_ui = $Margin/VBox/VBoxText/Text
onready var _add_ui = $Margin/VBox/VBoxButtons/HBoxAdd/Add
# TODO buttons 
onready var _clear_ui = $Margin/VBox/HBoxAction/Clear
onready var _close_ui = $Margin/VBox/HBoxAction/Close

func set_data(data: DialogueData) -> void:
	_data = data
	_actor_ui_fill()
	_init_connections()

func _actor_ui_fill() -> void:
	_actor_ui.clear()
	_actor_ui.add_item("None")
	for actor in _data.actors:
		if not actor.resources.empty():
			var image = load(actor.resources[0].path)
			image = _data.resize_texture(image, Vector2(16, 16))
			_actor_ui.add_icon_item(image, actor.name)
		else:
			_actor_ui.add_item(actor.name)

func _init_connections() -> void:
	pass
