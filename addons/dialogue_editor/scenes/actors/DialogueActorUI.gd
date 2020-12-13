# Dialogue actor UI for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _actor: DialogueActor
var _data: DialogueData

var _ui_style_selected: StyleBoxFlat

onready var _texture_ui = $HBox/Texture as TextureRect
onready var _name_ui = $HBox/Name as Label
onready var _del_ui = $HBox/Del as Button

func set_data(actor: DialogueActor, data: DialogueData):
	_actor = actor
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()

func _init_styles() -> void:
	pass # TODO int style

func _init_connections() -> void:
	if not _del_ui.is_connected("pressed", self, "_del_pressed"):
		_del_ui.connect("pressed", self, "_del_pressed")

func _del_pressed() -> void:
	_data.del_actor(_actor)

func _draw_view() -> void:
	# TODO _texture_ui.texture = 
	_name_ui.text = _actor.name
