# Dialogue actor UI for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _actor: DialogueActor
var _data: DialogueData

var _ui_style_selected: StyleBoxFlat

onready var _texture_ui = $HBox/Texture as TextureRect
onready var _name_ui = $HBox/Name as LineEdit
onready var _del_ui = $HBox/Del as Button

func actor() -> DialogueActor:
	return _actor

func set_data(actor: DialogueActor, data: DialogueData):
	_actor = actor
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()
	_draw_style()

func _init_styles() -> void:
	_ui_style_selected = StyleBoxFlat.new()
	_ui_style_selected.set_bg_color(Color("#868991"))

func _init_connections() -> void:
	if not _data.is_connected("actor_added", self, "_on_actor_action"):
		_data.connect("actor_added", self, "_on_actor_action")
	if not _data.is_connected("actor_removed", self, "_on_actor_action"):
		_data.connect("actor_removed", self, "_on_actor_action")
	if not _data.is_connected("actor_selection_changed", self, "_draw_style"):
		_data.connect("actor_selection_changed", self, "_draw_style")
	if not _data.is_connected("actor_resource_path_changed", self, "_on_actor_resource_path_changed"):
		_data.connect("actor_resource_path_changed", self, "_on_actor_resource_path_changed")
	if not _texture_ui.is_connected("gui_input", self, "_on_gui_input"):
		_texture_ui.connect("gui_input", self, "_on_gui_input")
	if not _name_ui.is_connected("gui_input", self, "_on_gui_input"):
		_name_ui.connect("gui_input", self, "_on_gui_input")
	if not _name_ui.is_connected("focus_exited", self, "_on_focus_exited"):
		_name_ui.connect("focus_exited", self, "_on_focus_exited")
	if not _name_ui.is_connected("text_changed", self, "_on_text_changed"):
		_name_ui.connect("text_changed", self, "_on_text_changed")
	if not _del_ui.is_connected("pressed", self, "_del_pressed"):
		_del_ui.connect("pressed", self, "_del_pressed")

func _on_actor_action(actor: DialogueActor) -> void:
	_draw_style()

func _on_focus_exited() -> void:
	_draw_style()

func _on_actor_resource_path_changed(resource) -> void:
	if not _actor.resources.empty() and _actor.resources[0] == resource:
		_draw_texture()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if not _data.selected_actor() == _actor:
					_data.selected_actor_set(_actor)
					_del_ui.grab_focus()
				else:
					_name_ui.set("custom_styles/normal", null)

func _on_text_changed(new_text: String) -> void:
	_actor.name = new_text

func _del_pressed() -> void:
	_data.del_actor(_actor)

func _draw_view() -> void:
	_draw_texture()
	_name_ui.text = _actor.name

func _draw_texture() -> void:
	if not _actor.resources.empty():
		var image = load(_actor.resources[0].path)
		image = _data.resize_texture(image, Vector2(16, 16))
		_texture_ui.texture = image

func _draw_style() -> void:
	if _data.selected_actor() == _actor:
		_name_ui.set("custom_styles/normal", _ui_style_selected)
	else:
		_name_ui.set("custom_styles/normal", null)
