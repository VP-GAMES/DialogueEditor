# DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends Control

var _editor: EditorPlugin
var _data:= DialogueData.new()

onready var _save_ui = $VBox/Margin/HBox/Save as Button
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
	_load_data()
	_data.set_editor(editor)
	_data_to_childs()

func _init_connections() -> void:
	if not _save_ui.is_connected("pressed", self, "save_data"):
		assert(_save_ui.connect("pressed", self, "save_data") == OK)
	if not _tabs_ui.is_connected("tab_changed", self, "_on_tab_changed"):
		assert(_tabs_ui.connect("tab_changed", self, "_on_tab_changed") == OK)

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
