# Dialogues view for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends HBoxContainer

var _data: DialogueData
var _split_viewport_size = 0

onready var _split_ui = $Split
onready var _scenes_ui = $Split/Scenes

func set_data(data: DialogueData) -> void:
	_data = data
	_scenes_ui.set_data(data)

func _ready() -> void:
	_init_connections()

func _init_connections() -> void:
	if not _split_ui.is_connected("dragged", self, "_on_split_dragged"):
		_split_ui.connect("dragged", self, "_on_split_dragged")

func _process(delta):
	if _split_viewport_size != rect_size.x:
		_split_viewport_size = rect_size.x
		_init_split_offset()

func _init_split_offset() -> void:
	var offset = 215
	if _data:
		offset = _data.setting_scenes_split_offset()
	_split_ui.set_split_offset(-rect_size.x / 2 + offset)

func _on_split_dragged(offset: int) -> void:
	if _data != null:
		var value = -(-rect_size.x / 2 - offset)
		_data.setting_scenes_split_offset_put(value)