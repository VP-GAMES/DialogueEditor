extends Control

const SETTINGS_DIALOGUES_SELECTED_DIALOGUE = "dialogue_editor/dialogues_selected_dialogue"

const DialogueManager = preload("res://addons/dialogue_editor/DialogueManager.gd")
const DialogueManagerName = "DialogueManager"
var dialogueManagerAdded  = false
var dialogueManager

func _ready():
	if not get_tree().get_root().has_node(DialogueManagerName):
		dialogueManager = DialogueManager.new()
		_init_dialogue_manager()
	else:
		dialogueManager = get_tree().get_root().has_node(DialogueManagerName)
		_init_dialogue_manager()

func _init_dialogue_manager() -> void:
	dialogueManager.started_from_editor = true
	dialogueManager.load_data()
	dialogueManager.name = DialogueManagerName
	get_tree().get_root().call_deferred("add_child", dialogueManager)

func _process(delta):
	if not dialogueManagerAdded and ProjectSettings.has_setting(SETTINGS_DIALOGUES_SELECTED_DIALOGUE):
		if get_tree().get_root().has_node(DialogueManagerName):
			dialogueManagerAdded = true
			var dialogue_name = ProjectSettings.get_setting(SETTINGS_DIALOGUES_SELECTED_DIALOGUE)
			dialogueManager.start_dialogue(dialogue_name)
			if not dialogueManager.is_connected("dialogue_ended", self, "_on_dialogue_ended"):
				assert(dialogueManager.connect("dialogue_ended", self, "_on_dialogue_ended") == OK)

func _on_dialogue_ended(dialogue) -> void:
	get_tree().quit()

