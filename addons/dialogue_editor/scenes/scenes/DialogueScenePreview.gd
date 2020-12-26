extends Control


func _ready() -> void:
	var DialogueActorDialog = load("res://addons/dialogue_editor/default/DialogueActorLeft.tscn")
	var scene = DialogueActorDialog.instance()
	add_child(scene)
