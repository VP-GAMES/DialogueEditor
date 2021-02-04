tool
extends "res://addons/dialogue_editor/model/DialogueDialog.gd"

onready var _timer = $Timer
var _text: = ""

func _ready() -> void:
	_timer.connect("timeout", self, "_on_timer_timeout")

func _on_timer_timeout() -> void:
	if _sentence and _text.length() != _sentence.texte_events[0].text.length():
		_text = _sentence.texte_events[0].text.substr (0, _text.length() + 1)
		_text()

func _text() -> void:
	if _sentence.text_exists():
		_text_ui.visible = true
		_text_ui.text = _text
	else:
		_text_ui.visible = false
