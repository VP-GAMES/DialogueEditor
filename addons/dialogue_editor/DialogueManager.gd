# DialogueManager used for dialogues in games : MIT License
# @author Vladimir Petrenko
extends Node

var _data: = DialogueData.new()
var _dialogue
var _sentence

func _ready() -> void:
	_data = ResourceLoader.load(_data.PATH_TO_SAVE) as DialogueData

func actual_dialogue() -> String:
	return _dialogue.name

func start_dialogue(dialogue_name: String) -> void:
	if not _data.dialogue_exists(dialogue_name):
		printerr("Dialogue ", dialogue_name,  " doesn't exists")
		_dialogue = null
		_sentence = null
		return
	_dialogue = _data.dialogue_by_name(dialogue_name) as DialogueDialogue
	var node_start = _dialogue.node_start() as DialogueNode
	if node_start and not node_start.sentences[0].node is DialogueEmpty:
		_sentence = _node_to_dialogue_sentence(node_start.sentences[0].node)

func _node_to_dialogue_sentence(node: DialogueNode) -> DialogueSentence:
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
