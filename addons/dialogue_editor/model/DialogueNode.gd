# Dialogue node for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name DialogueNode, "res://addons/dialogue_editor/icons/Node.png"

enum { START, END, SENTENCE }

export (String) var uuid
export (int) var type
export (String) var name
export (Vector2) var position
export (Resource) var actor # DialogueActor
export (String) var texture_uuid
export (Array) var subnodes = [] # {"text": "", "event": null, "node": null}
