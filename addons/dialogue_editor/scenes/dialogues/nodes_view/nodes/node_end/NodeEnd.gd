# Node end for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends "res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/NodeBase.gd"

func _ready() -> void:
	set_slot(0, true, 0, Color(1, 1, 1), false, 0, Color(1, 1, 1))

func selected_slot() -> Vector2:
	return Vector2.ZERO

func save_data():
	var dict = {
		"filename" : get_filename(),
		"name" : name,
		"editor_position": global_position()
		}
	return dict
