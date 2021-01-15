# Node start for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends "res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/NodeBase.gd"

func _ready() -> void:
	set_slot(0, false, 0, Color(1, 1, 1), true, 0, Color(1, 1, 1))

func selected_slot() -> Vector2:
	return Vector2.ZERO
