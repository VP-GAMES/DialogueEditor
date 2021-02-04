# Dialogue2D as custom type for DialogueEditor : MIT License
# @author Vladimir Petrenko
tool
extends Area2D
class_name Dialogue2D

var inside
var dialogueManager
const DialogueManagerName = "DialogueManager"

export(String) var dialogue_name
export(bool) var autostart = false
export(String) var activate = "action"
export(String) var cancel = "cancel"

func _ready() -> void:
	if get_tree().get_root().has_node(DialogueManagerName):
		dialogueManager = get_tree().get_root().get_node(DialogueManagerName)
	if not is_connected("body_entered", self, "_on_body_entered"):
		assert(connect("body_entered", self, "_on_body_entered") == OK)
	if not is_connected("body_exited", self, "_on_body_exited"):
		assert(connect("body_exited", self, "_on_body_exited") == OK)

func _on_body_entered(body: Node) -> void:
	inside = true
	if autostart:
		_start_dialogue()

func _on_body_exited(body: Node) -> void:
	inside = false
	if dialogueManager:
		if dialogueManager.is_started():
			dialogueManager.cancel_dialogue()

func _input(event: InputEvent):
	if inside and dialogueManager:
		if event.is_action_released(activate):
			_start_dialogue()
		if event.is_action_released(activate):
			dialogueManager.next_sentence()
		if event.is_action_released(cancel):
			dialogueManager.cancel_dialogue()

func _start_dialogue() -> void:
	if not dialogueManager.is_started():
		dialogueManager.start_dialogue(dialogue_name)
		if autostart:
			dialogueManager.next_sentence()
