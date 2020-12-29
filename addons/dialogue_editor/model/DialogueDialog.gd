tool
extends Control

var _sentence: DialogueSentence
var _buttons_array = []

onready var _texture_ui = $Texture
onready var _name_ui = $Name
onready var _text_ui = $Text
onready var _button_ui = $Button

func sentence() -> DialogueSentence:
	return _sentence

func sentence_set(sentence: DialogueSentence) -> void:
	_sentence = sentence
	_texture()
	_name()
	_text()
	_buttons()

func _texture() -> void:
	var texture = null
	if _sentence and _sentence.texture_uuid:
		texture = _sentence.actor.texture_by_uuid(_sentence.texture_uuid)
	_texture_ui.texture = texture

func _name() -> void:
	if _sentence and _sentence.actor and not _sentence.actor.name_exists():
		_name_ui.text = _sentence.actor.name

func _text() -> void:
	if _sentence.text_exists():
		_text_ui.visible = true
		_text_ui.text = _sentence.texte_events[0].text
		if _sentence.texte_events[0].event:
			print("TODO DialogueManager emit_signal for single text")
	else:
		_text_ui.visible = false

func _buttons() -> void:
	_buttons_clear()
	if _sentence.buttons_exists():
		_button_ui.visible = true
		_buttons_generate()
	else:
		_button_ui.visible = false

func _buttons_clear() -> void:
	for button_ui in _buttons_array:
		if not button_ui == _button_ui:
			remove_child(button_ui)
			button_ui.queue_free()

func _buttons_generate() -> void:
	_buttons_array.append(_button_ui)
	for index in range(1, _sentence.buttons_count()):
		var button_ui = _button_ui.duplicate()
		_buttons_array.append(button_ui)
	var margin = 0.01
	var offset = margin + _button_ui.anchor_bottom - _button_ui.anchor_top
	for index in range(_buttons_array.size() - 1, -1, -1):
		var button_ui = _buttons_array[index] as Button
		button_ui.anchor_top = _button_ui.anchor_top - offset * index
		button_ui.anchor_bottom = _button_ui.anchor_bottom - offset * index
		button_ui.text = _sentence.texte_events[index].text
		if _sentence.texte_events[index].event:
			button_ui.connect("pressed", self, "_on_button_pressed", [_sentence.texte_events[index].event])
		add_child(button_ui)

func _on_button_pressed(event_name: String) -> void:
	print("TODO DialogueManager emit_signal for button")
