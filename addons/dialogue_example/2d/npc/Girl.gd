extends Area2D

var inside
var dialogueManager
const DialogueManagerName = "DialogueManager"

export(String) var dialogue_name = DialogueMangerDialogues.SIMPLE

func _ready() -> void:
	if get_tree().get_root().has_node(DialogueManagerName):
		dialogueManager = get_tree().get_root().has_node(DialogueManagerName)
	if not is_connected("body_entered", self, "_on_body_entered"):
		assert(connect("body_entered", self, "_on_body_entered") == OK)
	if not is_connected("body_exited", self, "_on_body_exited"):
		assert(connect("body_exited", self, "_on_body_exited") == OK)

func _on_body_entered(body: Node) -> void:
	inside = true

func _on_body_exited(body: Node) -> void:
	inside = false

func _input(event: InputEvent):
	if event.is_action_released("ui_accept"):
		if inside and dialogueManager:
			if not dialogueManager.is_started():
				dialogueManager.start_dialogue()
