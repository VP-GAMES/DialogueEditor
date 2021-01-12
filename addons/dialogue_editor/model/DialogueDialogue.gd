# Dialogue dialogue for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name DialogueDialogue, "res://addons/dialogue_editor/icons/Dialogue.png"

export (String) var name = ""
export (Vector2) var scrolloffset = Vector2.ZERO
export (Array) var nodes = [] # DialogueNode
