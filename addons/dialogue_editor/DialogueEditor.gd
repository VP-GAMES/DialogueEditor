# DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends Control

var _editor: EditorPlugin
var _data:= DialogueData.new()
var localization_editor

onready var _save_ui = $VBox/Margin/HBox/Save as Button
onready var _label_ui = $VBox/Margin/HBox/Label as Label
onready var _languages_ui = $VBox/Margin/HBox/Language as OptionButton
onready var _tabs_ui = $VBox/Tabs as TabContainer
onready var _actors_ui = $VBox/Tabs/Actors as VBoxContainer
onready var _scenes_ui = $VBox/Tabs/Scenes as HBoxContainer
onready var _dialogues_ui = $VBox/Tabs/Dialogues as HBoxContainer

const IconResourceActor = preload("res://addons/dialogue_editor/icons/Actor.png")
const IconResourceScene = preload("res://addons/dialogue_editor/icons/Scene.png")
const IconResourceDialogue = preload("res://addons/dialogue_editor/icons/Dialogue.png")

func _ready() -> void:
	_tabs_ui.set_tab_icon(0, IconResourceActor)
	_tabs_ui.set_tab_icon(1, IconResourceScene)
	_tabs_ui.set_tab_icon(2, IconResourceDialogue)

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_init_connections()
	_data.set_editor(editor)
	_load_data()
	_data_to_childs()
	_init_localization()

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
	init_languages()

func _init_connections() -> void:
	if not _save_ui.is_connected("pressed", self, "save_data"):
		assert(_save_ui.connect("pressed", self, "save_data") == OK)
	if not _tabs_ui.is_connected("tab_changed", self, "_on_tab_changed"):
		assert(_tabs_ui.connect("tab_changed", self, "_on_tab_changed") == OK)

func get_data() -> DialogueData:
	return _data

func _load_data() -> void:
	_data.init_data()

func _on_tab_changed(tab: int) -> void:
	_data_to_childs()

func _data_to_childs() -> void:
	_actors_ui.set_data(_data)
	_scenes_ui.set_data(_data)
	_dialogues_ui.set_data(_data)

func save_data() -> void:
	_data.save()

func _init_localization() -> void:
	if _data.setting_localization_editor_enabled():
		_label_ui.show()
		_languages_ui.show()
	else:
		_label_ui.hide()
		_languages_ui.hide()

var _locales
func init_languages() -> void:
	_languages_ui.clear()
	_locales = localization_editor.get_data().locales()
	var index: = -1
	for i in range(_locales.size()):
		_languages_ui.add_item(TranslationServer.get_locale_name(_locales[i]))
		if _locales[i] in _data.get_locale():
			index = i
	_languages_ui.select(index)
	if not _languages_ui.is_connected("item_selected", self, "_on_item_selected"):
		assert(_languages_ui.connect("item_selected", self, "_on_item_selected") == OK)

func _on_item_selected(index: int) -> void:
	_data.set_locale(_locales[index])
