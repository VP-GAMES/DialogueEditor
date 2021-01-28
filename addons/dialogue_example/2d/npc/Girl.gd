extends Area2D

var inside
var dialogueManager
const DialogueManagerName = "DialogueManager"

export(String) var dialogue_name = "Simple"

func _ready() -> void:
	if get_tree().get_root().has_node(DialogueManagerName):
		dialogueManager = get_tree().get_root().get_node(DialogueManagerName)
	if not is_connected("body_entered", self, "_on_body_entered"):
		assert(connect("body_entered", self, "_on_body_entered") == OK)
	if not is_connected("body_exited", self, "_on_body_exited"):
		assert(connect("body_exited", self, "_on_body_exited") == OK)

func _on_body_entered(body: Node) -> void:
	inside = true

func _on_body_exited(body: Node) -> void:
	inside = false
	if dialogueManager:
		if dialogueManager.is_started():
			dialogueManager.cancel_dialogue()

func _input(event: InputEvent):
	if inside and dialogueManager:
		if event.is_action_released("action"):
			if not dialogueManager.is_started():
				dialogueManager.start_dialogue(dialogue_name)
		if event.is_action_released("action"):
			dialogueManager.next_sentence()
		if event.is_action_released("cancel"):
			dialogueManager.cancel_dialogue()
