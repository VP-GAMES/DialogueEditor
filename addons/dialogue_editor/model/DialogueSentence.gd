# Dialogue dialog for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name DialogueSentence, "res://addons/dialogue_editor/icons/Sentence.png"

export (String) var scene = ""
export (Resource) var actor # DialogueActor
export (String) var texture_uuid
export (Array) var texte_events = [{"text": "", "event": null, "next": null}]

func text_exists() -> bool:
	return texte_events.size() == 1

func buttons_exists() -> bool:
	return texte_events.size() > 1

func buttons_count() -> int:
	return texte_events.size()
