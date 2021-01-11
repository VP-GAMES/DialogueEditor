# Dialogue dialogue for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name DialogueDialogue, "res://addons/dialogue_editor/icons/Dialogue.png"

export (String) var name = ""
export (Vector2) var scrolloffset = Vector2(0, 0)
export (Array) var nodes = []
export (Array) var connections = []
