extends Control

const SETTINGS_DIALOGUES_SELECTED_DIALOGUE = "dialogue_editor/dialogues_selected_dialogue"

const DialogueManager = preload("res://addons/dialogue_editor/DialogueManager.gd")
const DialogueManagerName = "DialogueManager"
var dialogueManagerAdded  = false
var dialogueManager

onready var _timer_ui = $Timer
onready var _event_ui = $Event

func _ready():
	if not get_tree().get_root().has_node(DialogueManagerName):
		dialogueManager = DialogueManager.new()
		_init_dialogue_manager()
		get_tree().get_root().call_deferred("add_child", dialogueManager)
	else:
		dialogueManager = get_tree().get_root().get_node(DialogueManagerName)
		_init_dialogue_manager()
	var locale = _setting_dialogue_editor_locale()
	if locale:
		TranslationServer.set_locale(locale)

func _init_dialogue_manager() -> void:
	dialogueManager.started_from_editor = true
	dialogueManager.load_data()
	dialogueManager.name = DialogueManagerName

func _setting_dialogue_editor_locale():
	if ProjectSettings.has_setting("dialogue_editor/dialogues_editor_locale"):
		return ProjectSettings.get_setting("dialogue_editor/dialogues_editor_locale")
	return null

func _process(delta):
	if not dialogueManagerAdded and ProjectSettings.has_setting(SETTINGS_DIALOGUES_SELECTED_DIALOGUE):
		if get_tree().get_root().has_node(DialogueManagerName):
			dialogueManagerAdded = true
			var dialogue_name = ProjectSettings.get_setting(SETTINGS_DIALOGUES_SELECTED_DIALOGUE)
			if not dialogueManager.is_connected("dialogue_ended", self, "_on_dialogue_ended_canceled"):
				assert(dialogueManager.connect("dialogue_ended", self, "_on_dialogue_ended_canceled") == OK)
			if not dialogueManager.is_connected("dialogue_canceled", self, "_on_dialogue_ended_canceled"):
				assert(dialogueManager.connect("dialogue_canceled", self, "_on_dialogue_ended_canceled") == OK)
			if not dialogueManager.is_connected("dialogue_event", self, "_on_dialogue_event"):
				assert(dialogueManager.connect("dialogue_event", self, "_on_dialogue_event") == OK)
			dialogueManager.start_dialogue(dialogue_name)

func _on_dialogue_ended_canceled(dialogue) -> void:
	get_tree().quit()

func _on_dialogue_event(event: String) -> void:
	_event_ui.text = "EVENT: -> " +  event
	_event_ui.visible = true
	_timer_ui.start()
	if not _timer_ui.is_connected("timeout", self, "_on_timeout"):
		assert(_timer_ui.connect("timeout", self, "_on_timeout") == OK)

func _on_timeout() -> void:
	_event_ui.visible = false
