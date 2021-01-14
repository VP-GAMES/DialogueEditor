# Dialogue node for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name DialogueNode, "res://addons/dialogue_editor/icons/Node.png"

export (String) var name
export (String) var filename
export (Vector2) var editor_position
export (Resource) var actor # DialogueActor
export (String) var texture_uuid # 
export (Array) var subnodes = [] # {"text": "", "event": null, "node": null}