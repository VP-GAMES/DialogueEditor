extends Control

const DialogueManager = preload("res://addons/dialogue_editor/DialogueManager.gd")
var dialogueManager
var dialogueManagerAdded  = false

func _ready():
	dialogueManager = DialogueManager.new()
	dialogueManager.load_data()
	dialogueManager.name = "DialogueManager"
	get_tree().get_root().call_deferred("add_child", dialogueManager)

func _process(delta):
	if not dialogueManagerAdded:
		if get_tree().get_root().has_node(dialogueManager.name):
			dialogueManagerAdded = true
			dialogueManager.start_dialogue("DialogueWithLora")
			if not dialogueManager.is_connected("dialogue_ended", self, "_on_dialogue_ended"):
				assert(dialogueManager.connect("dialogue_ended", self, "_on_dialogue_ended") == OK)

func _on_dialogue_ended(dialogue) -> void:
	get_tree().quit()
