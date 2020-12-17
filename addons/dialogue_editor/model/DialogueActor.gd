# Dialogue actor for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name DialogueActor, "res://addons/dialogue_editor/icons/Actor.png"

var uuid
export (String) var name
export (Array) var textures = [] # List of Textures
