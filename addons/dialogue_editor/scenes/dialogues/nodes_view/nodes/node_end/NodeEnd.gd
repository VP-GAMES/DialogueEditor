# Node end for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends "res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/NodeBase.gd"

func _slots_draw() -> void:
	set_slot(0, true, 0, Color(1, 1, 1), false, 0, Color(1, 1, 1))
