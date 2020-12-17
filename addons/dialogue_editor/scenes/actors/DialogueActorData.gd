# Dialogue actor data for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _data: DialogueData
var _actor: DialogueActor

onready var _name_ui = $MarginData/VBox/HBox/Name as LineEdit
onready var _add_ui = $MarginData/VBox/HBoxTextures/Add as Button

func set_data(data: DialogueData):
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	if not _data.is_connected("selected_actor_changed", self, "_on_selected_actor_changed"):
		_data.connect("selected_actor_changed", self, "_on_selected_actor_changed")

func _on_selected_actor_changed() -> void:
	_actor = _data.selected_actor()
	_update_view()

func _update_view() -> void:
	if _actor:
		_draw_view()
	else:
		_clear_view()

func _draw_view() -> void:
	_name_ui.set_editable(false)
	_name_ui.text = _actor.name

func _clear_view() -> void:
	_name_ui.set_editable(true)
