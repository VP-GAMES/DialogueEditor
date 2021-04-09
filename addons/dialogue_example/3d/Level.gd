# DialogueEditor example of Dialogues usage: MIT License
# @author Vladimir Petrenko
extends Spatial

var dialogueManager

onready var _timer_ui = $Timer
onready var _error_ui = $CanvasError as CanvasLayer
onready var _flag_red_ui = $FlagRed as Node
onready var _flag_yellow_ui = $FlagYellow as Node

func _ready() -> void:
	if get_tree().get_root().has_node("DialogueManager"):
		_error_ui.queue_free()
		dialogueManager = get_tree().get_root().get_node("DialogueManager")
		if not dialogueManager.is_connected("dialogue_event", self, "_on_dialogue_event"):
				assert(dialogueManager.connect("dialogue_event", self, "_on_dialogue_event") == OK)

func _on_dialogue_event(event: String) -> void:
	if event == DialogueEvents.QUESTION_EVENT_RIGHT or event == DialogueEvents.QUESTION_EVENT_WRONG:
		_flag_yellow_ui.visible = event == DialogueEvents.QUESTION_EVENT_RIGHT
		_flag_red_ui.visible = event == DialogueEvents.QUESTION_EVENT_WRONG
		_timer_ui.start()
		if not _timer_ui.is_connected("timeout", self, "_on_timeout"):
			assert(_timer_ui.connect("timeout", self, "_on_timeout") == OK)

func _on_timeout() -> void:
	_reset_flags()

func _reset_flags() -> void:
	_flag_yellow_ui.visible = false
	_flag_red_ui.visible = false
