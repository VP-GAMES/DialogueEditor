# DialogueManager used for dialogues in games : MIT License
# @author Vladimir Petrenko
extends Node

signal dialogue_started(dialogue)
signal dialogue_event(event)
signal dialogue_ended(dialogue)

var started_from_editor = false

var _data: = DialogueData.new()
var _data_loaded = false
var _dialogue
var _sentence
var _scene
var _node

func _ready() -> void:
	if not _data_loaded:
		load_data()

func load_data() -> void:
	if not _data_loaded:
		_data = ResourceLoader.load(_data.PATH_TO_SAVE) as DialogueData

func actual_dialogue() -> String:
	return _dialogue.name

func start_dialogue(dialogue_name: String) -> void:
	if not _data.dialogue_exists(dialogue_name):
		printerr("Dialogue ", dialogue_name,  " doesn't exists")
		_dialogue = null
		_scene = null
		_node = null
		return
	_dialogue = _data.dialogue_by_name(dialogue_name) as DialogueDialogue
	_node = _dialogue.node_start() as DialogueNode
	if _node:
		_next_sentence(0)
		emit_signal("dialogue_started", _dialogue.name)

func _input(event: InputEvent):
	if event.is_action_released("ui_accept"):
		_next_sentence_action()

func _next_sentence_action() -> void:
		var index = -1
		if started_from_editor:
			index = _node.selected_sentence_index()
		if _node.sentences.size() == 1:
			index = 0
		if index != -1:
			_next_sentence(index)

func _next_sentence(index) -> void:
	if _node and not _node.sentences[index].node is DialogueEmpty:
		_sentence = _node_to_dialogue_sentence(_node.sentences[index].node)
		if _sentence.scene:
			_draw_view()
			_node = _node.sentences[index].node
		else:
			_clear_sentences()
			emit_signal("dialogue_ended", _dialogue.name)
			_dialogue = null
			_scene = null
			_node = null

func _node_to_dialogue_sentence(node: DialogueNode):
	var dialogueSentence = DialogueSentence.new()
	dialogueSentence.scene = node.scene
	dialogueSentence.actor = node.actor
	dialogueSentence.texture_uuid = node.texture_uuid
	dialogueSentence.texte_events = []
	for sentence in node.sentences:
		var text_event = {"text": "", "event": null, "next": null}
		text_event.text = sentence.text
		if not sentence.event.empty():
			text_event.event = sentence.event
		if not sentence.node is DialogueEmpty:
			text_event.next = sentence.node.uuid
		dialogueSentence.texte_events.append(text_event)
	return dialogueSentence

func _draw_view() -> void:
	_clear_sentences()
	_draw_sentence()

func _clear_sentences() -> void:
	for scene in _data.scenes:
		var scenePath = scene.resource
		var sceneName = _data.filename_only(scenePath)
		if get_tree().get_root().has_node(sceneName):
			var node = get_tree().get_root().get_node(sceneName)
			get_tree().get_root().remove_child(node)
			node.queue_free()

func _draw_sentence() -> void:
	if _sentence.scene:
		var scenePath = _sentence.scene
		var SentenceScene = load(scenePath)
		_scene = SentenceScene.instance()
		_scene.name = _data.filename_only(scenePath)
		get_tree().get_root().add_child(_scene)
		_connect_gui_input()
		_scene.sentence_set(_sentence)
		if _sentence.texte_events.size() == 1:
			var event_name = _sentence.texte_events[0].event
			if event_name:
				emit_signal("dialogue_event", event_name)
		elif _sentence.texte_events.size() > 1:
			_connect_buttons()

func _connect_gui_input() -> void:
	if not _scene.is_connected("gui_input", self, "_on_gui_input"):
		_scene.connect("gui_input", self, "_on_gui_input")

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == BUTTON_LEFT:
			if started_from_editor:
				_next_sentence_action()

func _connect_buttons() -> void:
	var buttons_array = _scene.buttons()
	for index in range(buttons_array.size() - 1, -1, -1):
		var index_reverse = buttons_array.size() - (index +1)
		var button_ui = buttons_array[index] as Button
		if not button_ui.is_connected("pressed", self, "_on_button_pressed"):
			assert(button_ui.connect("pressed", self, "_on_button_pressed", [index_reverse]) == OK)

func _on_button_pressed(button_index: int) -> void:
	var event_name = _sentence.texte_events[button_index].event
	if event_name:
		emit_signal("dialogue_event", event_name)
	_next_sentence(button_index)
