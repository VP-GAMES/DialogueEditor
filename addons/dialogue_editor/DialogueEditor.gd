# DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends Control

var _editor: EditorPlugin
var _data:= DialogueData.new()

onready var _save_ui = $VBox/Margin/HBox/Save
onready var _actors_ui = $VBox/Tabs/Actors
onready var _scenes_ui = $VBox/Tabs/Scenes

func set_editor(editor: EditorPlugin) -> void:
	_editor = editor
	_init_connections()
	_data.set_editor(editor)
	_data_to_childs()

func _ready() -> void:
	set_editor(null)

func _init_connections() -> void:
	if not _save_ui.is_connected("pressed", self, "save_data"):
		_save_ui.connect("pressed", self, "save_data")

func _data_to_childs() -> void:
	_actors_ui.set_data(_data)
	_scenes_ui.set_data(_data)

func save_data() -> void:
	_data.save()
