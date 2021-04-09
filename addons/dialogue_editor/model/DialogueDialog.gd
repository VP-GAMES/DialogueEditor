# Dialogue sentence for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends Control

var _localizationManager
const _localizationManagerName = "localizationManager"

var _sentence: DialogueSentence
var _buttons_array = []

export(bool) var show_name = true

onready var _texture_ui = $Texture
onready var _name_ui = $Name
onready var _text_ui = $Text
onready var _button_ui = $Button

func sentence() -> DialogueSentence:
	return _sentence

func buttons() -> Array:
	return _buttons_array

func _ready() -> void:
	if get_tree().get_root().has_node(_localizationManagerName):
		_localizationManager = get_tree().get_root().get_node(_localizationManagerName)
		if not _localizationManager.is_connected("translation_changed", self, "_update_translation_from_manager"):
			_localizationManager.connect("translation_changed", self, "_update_translation_from_manager")

func _update_translation_from_manager() -> void:
	_text()
	_buttons()

func sentence_set(sentence: DialogueSentence) -> void:
	_sentence = sentence
	_texture()
	_name()
	_text()
	_buttons()

func _texture() -> void:
	var texture = null
	if _sentence and _sentence.texture_uuid:
		texture = _sentence.actor.resource_by_uuid(_sentence.texture_uuid)
		if texture:
			_texture_ui.texture = texture

func _name() -> void:
	if show_name and _sentence and _sentence.actor:
		var uiname = _sentence.actor.uiname
		if uiname and not uiname.empty():
			_name_ui.text = TranslationServer.tr(uiname)
		else:
			_name_ui.text = _sentence.actor.name
	else:
		_name_ui.text = ""

func _text() -> void:
	if _sentence.text_exists():
		_text_ui.visible = true
		if _localizationManager:
			_text_ui.text = _localizationManager.tr(_sentence.texte_events[0].text)
		else:
			_text_ui.text = _sentence.texte_events[0].text
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
	_buttons_array = []

func _buttons_generate() -> void:
	_buttons_array.append(_button_ui)
	for index in range(1, _sentence.buttons_count()):
		var button_ui = _button_ui.duplicate()
		_buttons_array.append(button_ui)
	var margin = 0.01
	var offset = margin + _button_ui.anchor_bottom - _button_ui.anchor_top
	for index in range(_buttons_array.size() - 1, -1, -1):
		var index_reverse = _buttons_array.size() - (index +1)
		var button_ui = _buttons_array[index] as Button
		button_ui.anchor_top = _button_ui.anchor_top - offset * index
		button_ui.anchor_bottom = _button_ui.anchor_bottom - offset * index
		if _localizationManager:
			_text_ui.text = _localizationManager.tr(_sentence.texte_events[index_reverse].text)
		else:
			button_ui.text = _sentence.texte_events[index_reverse].text
	for child in get_children():
		for button_ui in _buttons_array:
			if child == button_ui:
				remove_child(button_ui)
	for button_ui in _buttons_array:
		add_child(button_ui)
