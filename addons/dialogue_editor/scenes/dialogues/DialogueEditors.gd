# Dialogues editors view for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends MarginContainer

var _data: DialogueData

const DialogueNodesView = preload("res://addons/dialogue_editor/scenes/dialogues/nodes_view/DialogueNodesView.tscn")
const DialogueBricksView = preload("res://addons/dialogue_editor/scenes/dialogues/bricks_view/DialogueBricksView.tscn")

func set_data(data: DialogueData) -> void:
	_data = data
	_init_connections()
	_update_view()

func _init_connections() -> void:
	_data.connect("dialogue_view_selection_changed", self, "_update_view")

func _update_view() -> void:
	_clear_view()
	_draw_view()

func _clear_view() -> void:
	for child_ui in get_children():
		remove_child(child_ui)
		child_ui.queue_free()

func _draw_view() -> void:
	var type = _data.setting_dialogues_editor_type()
	match type:
		"NODES":
			_draw_nodes_view()
		"BRICKS":
			_draw_bricks_view()

func _draw_nodes_view() -> void:
	var nodes_ui = DialogueNodesView.instance()
	add_child(nodes_ui)

func _draw_bricks_view() -> void:
	var bricks_ui = DialogueBricksView.instance()
	add_child(bricks_ui)
