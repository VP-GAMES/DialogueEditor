# DialogueManager used for dialogues in games : MIT License
# @author Vladimir Petrenko
extends Node

signal dialogue_started(dialogue)
signal dialogue_ended(dialogue)

var _data: = DialogueData.new()
var _data_loaded = false
var _dialogue
var _sentence
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
	print(_data.dialogues)
	if not _data.dialogue_exists(dialogue_name):
		printerr("Dialogue ", dialogue_name,  " doesn't exists")
		_dialogue = null
		_node = null
		return
	_dialogue = _data.dialogue_by_name(dialogue_name) as DialogueDialogue
	_node = _dialogue.node_start() as DialogueNode
	if _node:
		_next_sentence()
		emit_signal("dialogue_started", _dialogue.name)

func _input(event):
	if event.is_action_released("ui_accept"):
		_next_sentence()

func _next_sentence() -> void:
	if _node and not _node.sentences[0].node is DialogueEmpty:
		_sentence = _node_to_dialogue_sentence(_node.sentences[0].node)
		if _sentence.scene:
			_draw_view()
			_node = _node.sentences[0].node
		else:
			_clear_sentences()
			emit_signal("dialogue_ended", _dialogue.name)
			_dialogue = null
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
		var scene = SentenceScene.instance()
		scene.name = _data.filename_only(scenePath)
		get_tree().get_root().add_child(scene)
		scene.sentence_set(_sentence)
