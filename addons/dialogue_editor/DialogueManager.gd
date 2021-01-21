# DialogueManager used for dialogues in games : MIT License
# @author Vladimir Petrenko
extends Node

var _data:= DialogueData.new()

func _ready() -> void:
	_data.init_data()
