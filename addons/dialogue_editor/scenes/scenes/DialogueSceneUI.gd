# Dialogue scene UI for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _scene
var _data: DialogueData

var _ui_style_selected: StyleBoxFlat

onready var _name_ui = $HBox/Name as Label
onready var _open_ui = $HBox/Open as Button
onready var _del_ui = $HBox/Del as Button

func scene():
	return _scene

func set_data(scene, data: DialogueData):
	_scene = scene
	_data = data
	_init_styles()
	_init_connections()
	_draw_view()
	_draw_style()

func _init_styles() -> void:
	_ui_style_selected = StyleBoxFlat.new()
	_ui_style_selected.set_bg_color(Color("#868991"))

func _init_connections() -> void:
	if not _data.is_connected("scene_added", self, "_on_scene_action"):
		_data.connect("scene_added", self, "_on_scene_action")
	if not _data.is_connected("scene_removed", self, "_on_scene_action"):
		_data.connect("scene_removed", self, "_on_scene_action")
	if not _data.is_connected("scene_selection_changed", self, "_draw_style"):
		_data.connect("scene_selection_changed", self, "_draw_style")
	if not _data.is_connected("scene_resource_path_changed", self, "_on_scene_resource_path_changed"):
		_data.connect("scene_resource_path_changed", self, "_on_scene_resource_path_changed")
#	if not _name_ui.is_connected("gui_input", self, "_on_gui_input"):
#		_name_ui.connect("gui_input", self, "_on_gui_input")
#	if not _name_ui.is_connected("focus_exited", self, "_on_focus_exited"):
#		_name_ui.connect("focus_exited", self, "_on_focus_exited")
#	if not _del_ui.is_connected("pressed", self, "_del_pressed"):
#		_del_ui.connect("pressed", self, "_del_pressed")

func _on_scene_action(scene) -> void:
	_draw_style()

func _on_focus_exited() -> void:
	_draw_style()

func _on_scene_resource_path_changed(resource) -> void:
	if not _scene.resources.empty() and _scene.resources[0] == resource:
		pass

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				if not _data.selected_scene() == _scene:
					_data.selected_scene_set(_scene)
					_del_ui.grab_focus()
				else:
					_name_ui.set("custom_styles/normal", null)

func _on_text_changed(new_text: String) -> void:
	_scene.name = new_text

func _del_pressed() -> void:
	_data.del_scene(_scene)

func _draw_view() -> void:
	_name_ui.text = _data.filename_only(_scene.resource)

func _draw_style() -> void:
	if _data.selected_scene() == _scene:
		_name_ui.set("custom_styles/normal", _ui_style_selected)
	else:
		_name_ui.set("custom_styles/normal", null)
