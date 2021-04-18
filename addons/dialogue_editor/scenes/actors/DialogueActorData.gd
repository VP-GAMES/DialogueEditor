# Dialogue actor data for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _data: DialogueData
var _actor: DialogueActor
var localization_editor

onready var _uiname_ui = $MarginData/VBox/HBoxUIName/UIName as LineEdit
onready var _dropdown_ui = $MarginData/VBox/HBoxUIName/Dropdown
onready var _add_ui = $MarginData/VBox/HBox/Add as Button
onready var _resources_ui = $MarginData/VBox/Resources as VBoxContainer
onready var _texture_ui = $MarginPreview/VBox/Texture as TextureRect

const DialogueActorDataResource = preload("res://addons/dialogue_editor/scenes/actors/DialogueActorDataResource.tscn")

func set_data(data: DialogueData):
	_data = data
	_texture_ui.set_data(data)
	_dropdown_ui_init()
	_init_connections()
	_update_view()
	_dropdown_ui.set_data(_data)

func _process(delta: float) -> void:
	if not localization_editor:
		_dropdown_ui_init()

func _dropdown_ui_init() -> void:
	if not localization_editor:
		localization_editor = get_tree().get_root().find_node("LocalizationEditor", true, false)
	if localization_editor:
		var data = localization_editor.get_data()
		if data:
			if not data.is_connected("data_changed", self, "_on_localization_data_changed"):
				data.connect("data_changed", self, "_on_localization_data_changed")
			if not data.is_connected("data_key_value_changed", self, "_on_localization_data_changed"):
				data.connect("data_key_value_changed", self, "_on_localization_data_changed")
			_on_localization_data_changed()

func _on_localization_data_changed() -> void:
	if _dropdown_ui:
		_dropdown_ui.clear()
		if localization_editor:
			for key in localization_editor.get_data().data.keys:
				_dropdown_ui.add_item(key.value)
			if _actor:
				_dropdown_ui.set_selected_by_value(_actor.uiname)

func _init_connections() -> void:
	if not _add_ui.is_connected("pressed", self, "_on_add_pressed"):
		assert(_add_ui.connect("pressed", self, "_on_add_pressed") == OK)
	if not _data.is_connected("actor_selection_changed", self, "_on_actor_selection_changed"):
		assert(_data.connect("actor_selection_changed", self, "_on_actor_selection_changed") == OK)

func _on_add_pressed() -> void:
	_actor.add_resource()

func _on_actor_selection_changed(actor: DialogueActor) -> void:
	_actor = actor
	_update_view()

func _init_actor_connections() -> void:
	if not _actor.is_connected("resource_added", self, "_on_resource_added"):
		assert(_actor.connect("resource_added", self, "_on_resource_added") == OK)
	if not _actor.is_connected("resource_removed", self, "_on_resource_removed"):
		assert(_actor.connect("resource_removed", self, "_on_resource_removed") == OK)
	if not _uiname_ui.is_connected("text_changed", self, "_on_uiname_changed"):
		assert(_uiname_ui.connect("text_changed", self, "_on_uiname_changed") == OK)
	if _data.setting_localization_editor_enabled():
		if not _dropdown_ui.is_connected("selection_changed_value", self, "_on_selection_changed_value"):
			assert(_dropdown_ui.connect("selection_changed_value", self, "_on_selection_changed_value") == OK)

func _on_resource_added(resource) -> void:
	_update_view()
	_resource_request_focus(resource)

func _on_resource_removed(resource) -> void:
	_update_view()

func _on_uiname_changed(new_text: String) -> void:
	_actor.change_uiname(new_text)

func _on_selection_changed_value(new_text: String) -> void:
	_actor.change_uiname(new_text)

func _update_view() -> void:
	if _data:
		_actor = _data.selected_actor()
		if _actor:
			_init_actor_connections()
			_clear_view()
			_draw_view()
		else:
			_clear_view()

func _draw_view() -> void:
	_uiname_ui_draw()
	_dropdown_ui_draw()
	_on_localization_data_changed()
	_add_ui.disabled = false
	for resource in _actor.resources:
		_draw_resource(resource)
		_draw_preview_texture()

func _uiname_ui_draw() -> void:
	_uiname_ui.visible = not _data.setting_localization_editor_enabled()
	_uiname_ui.text = _actor.uiname

func _dropdown_ui_draw() -> void:
	_dropdown_ui.visible = _data.setting_localization_editor_enabled()

func _clear_view() -> void:
	_add_ui.disabled = true
	for resource_ui in _resources_ui.get_children():
		_resources_ui.remove_child(resource_ui)
		resource_ui.queue_free()

func _draw_resource(resource) -> void:
	var resource_ui = DialogueActorDataResource.instance()
	_resources_ui.add_child(resource_ui)
	resource_ui.set_data(resource, _actor, _data)

func _resource_request_focus(resource) -> void:
	for resource_ui in _resources_ui.get_children():
		if resource_ui.resource() == resource:
			resource_ui.request_focus()

func _draw_preview_texture() -> void:
	if _actor and not _actor.resources.empty():
		_texture_ui.set_resource(_actor.resources[0])
	else:
		_texture_ui.set_resource(null)

func _draw_preview_clear() -> void:
		_texture_ui.set_resource(null)
