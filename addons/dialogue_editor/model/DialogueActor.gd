# Dialogue actor for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends Resource
class_name DialogueActor, "res://addons/dialogue_editor/icons/Actor.png"

export (String) var name = ""
export (Array) var resources = [] # List of Resources

func default_uuid() -> String:
	var uuid = null
	if not resources.empty() and resources.size() == 1:
		uuid = resources[0].uuid
	return uuid

func texture_by_uuid(uuid = null) -> Texture:
	var texture = null
	if not resources.empty():
		if resources.size() == 1:
			texture = resources[0].texture
		elif uuid and resources.size() > 1:
			for res in resources:
				if res.uuid == uuid:
					texture = load(res.path)
					break
	return texture

func name_exists() -> bool:
	return name and not name.empty()
