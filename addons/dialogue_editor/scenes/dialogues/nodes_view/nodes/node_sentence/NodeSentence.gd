# Node sentence for DialogueEditor: MIT License
# @author Vladimir Petrenko
tool
extends "res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/NodeBase.gd"

var _group = ButtonGroup.new()

onready var _scenes_ui = $PanelScene/HBox/Scene as OptionButton
onready var _add_ui = $PanelActor/HBox/Add as Button
onready var _actors_ui = $PanelActor/HBox/Actor as OptionButton
onready var _view_ui = $PanelTexture/HBoxTexture/View as Button
onready var _textures_ui = $PanelTexture/HBoxTexture/Texture as OptionButton
onready var _texture_ui = $Center/Texture

const PanelSentence = preload("res://addons/dialogue_editor/scenes/dialogues/nodes_view/nodes/node_sentence/PanelSentence.tscn")

func set_data(node: DialogueNode, dialogue: DialogueDialogue, data: DialogueData) -> void:
	_node = node
	_dialogue = dialogue
	_data = data
	._change_name()
	_init_connections()
	_update_view()

func _init_connections() -> void:
	._init_connections()
	if not _scenes_ui.is_connected("item_selected", self, "_on_item_scene_selected"):
		assert(_scenes_ui.connect("item_selected", self, "_on_item_scene_selected") == OK)
	if not _node.is_connected("scene_selection_changed", self, "_on_scene_selection_changed"):
		assert(_node.connect("scene_selection_changed", self, "_on_scene_selection_changed") == OK)
	if not _actors_ui.is_connected("item_selected", self, "_on_item_actor_selected"):
		assert(_actors_ui.connect("item_selected", self, "_on_item_actor_selected") == OK)
	if not _node.is_connected("actor_selection_changed", self, "_on_actor_selection_changed"):
		assert(_node.connect("actor_selection_changed", self, "_on_actor_selection_changed") == OK)
	if not _add_ui.is_connected("pressed", self, "_on_add_sentence_pressed"):
		assert(_add_ui.connect("pressed", self, "_on_add_sentence_pressed") == OK)
	if not _node.is_connected("sentence_added", self, "_on_sentence_added"):
		assert(_node.connect("sentence_added", self, "_on_sentence_added") == OK)
	if not _node.is_connected("sentence_removed", self, "_on_sentence_removed"):
		assert(_node.connect("sentence_removed", self, "_on_sentence_removed") == OK)
	if not _textures_ui.is_connected("item_selected", self, "_on_item_textures_selected"):
		assert(_textures_ui.connect("item_selected", self, "_on_item_textures_selected") == OK)
	if not _node.is_connected("texture_selection_changed", self, "_on_texture_selection_changed"):
		assert(_node.connect("texture_selection_changed", self, "_on_texture_selection_changed") == OK)
	if not _view_ui.is_connected("pressed", self, "_on_view_pressed"):
		assert(_view_ui.connect("pressed", self, "_on_view_pressed") == OK)
	if not _node.is_connected("view_selection_changed", self, "_on_view_selection_changed"):
		assert(_node.connect("view_selection_changed", self, "_on_view_selection_changed") == OK)
	if not _node.is_connected("sentence_event_visibility_changed", self, "_on_sentence_event_visibility_changed"):
		assert(_node.connect("sentence_event_visibility_changed", self, "_on_sentence_event_visibility_changed") == OK)
	if not _node.is_connected("sentence_selection_changed", self, "_on_sentence_selection_changed"):
		assert(_node.connect("sentence_selection_changed", self, "_on_sentence_selection_changed") == OK)

func _on_item_scene_selected(index: int) -> void:
	if index > 0:
		_node.change_scene(_data.scenes[index - 1].resource)
	else:
		_node.change_scene()

func _on_scene_selection_changed(scene: String) -> void:
	_dialogue.emit_signal_update_view()

func _on_item_actor_selected(index: int) -> void:
	if index > 0:
		_node.change_actor(_data.actors[index - 1])
	else:
		_node.change_actor()

func _on_actor_selection_changed(actor: DialogueActor) -> void:
	_dialogue.emit_signal_update_view()

func _on_add_sentence_pressed() -> void:
	_node.add_sentence()

func _on_sentence_added(sentence) -> void:
	_dialogue.emit_signal_update_view()

func _on_sentence_removed(sentence) -> void:
	_dialogue.emit_signal_update_view()

func _on_item_textures_selected(index: int) -> void:
	if index > 0:
		_node.change_texture_uuid(_node.actor.resources[index - 1].uuid)
	else:
		_node.change_texture_uuid()

func _on_texture_selection_changed(texture_uuid) -> void:
	_dialogue.emit_signal_update_view()

func _on_view_pressed() -> void:
	_node.change_texture_view(_view_ui.pressed)

func _on_view_selection_changed(texture_view) -> void:
	_dialogue.emit_signal_update_view()

func _on_sentence_event_visibility_changed(sentence) -> void:
	_dialogue.emit_signal_update_view()

func _on_sentence_selection_changed(sentence) -> void:
	_dialogue.emit_signal_update_view()

func _update_view() -> void:
	._update_view()
	_scenes_ui_fill_and_draw()
	_actors_ui_fill_and_draw()
	_textures_ui_fill_and_draw()
	_view_ui_fill_and_draw()
	_texture_ui_fill_and_draw()
	_sentences_draw_view()
	_slots_draw()
	offset = _node.position
	rect_size = Vector2.ZERO

func _scenes_ui_fill_and_draw() -> void:
	_scenes_ui.clear()
	_scenes_ui.disabled = true
	var select = -1
	if not _data.scenes.empty():
		_scenes_ui.disabled = false
		_scenes_ui.add_item("None", 0)
		_scenes_ui.set_item_metadata(0, "None")
		select = 0
		for index in range(_data.scenes.size()):
			var scene = _data.scenes[index]
			if _node.scene == scene.resource:
				select = index + 1
			_scenes_ui.add_item(_data.filename_only(scene.resource), index + 1)
			_scenes_ui.set_item_metadata(index + 1, scene.resource)
		_scenes_ui.select(select)

func _actors_ui_fill_and_draw() -> void:
	_actors_ui.clear()
	_actors_ui.disabled = true
	var select = -1
	if not _data.actors.empty():
		_actors_ui.disabled = false
		_actors_ui.add_item("None", 0)
		select = 0
		for index in range(_data.actors.size()):
			var actor = _data.actors[index]
			if _node.actor == actor:
				select = index + 1
			if not actor.resources.empty():
				var image = load(actor.resources[0].path)
				image = _data.resize_texture(image, Vector2(16, 16))
				_actors_ui.add_icon_item(image, actor.name, index)
			else:
				_actors_ui.add_item(actor.name, index + 1)
		_actors_ui.select(select)

func _textures_ui_fill_and_draw() -> void:
	_textures_ui.clear()
	_textures_ui.disabled = true
	var select = -1
	if not _node.is_actor_empty_object():
		if not _node.actor.resources.empty():
			_textures_ui.disabled = false
			_textures_ui.add_item("None", 0)
			select = 0
			for index in range(_node.actor.resources.size()):
				var resource = _node.actor.resources[index]
				if _node.texture_uuid == resource.uuid:
					select = index + 1
				_textures_ui.add_item(resource.name, index + 1)
			_textures_ui.select(select)

func _view_ui_fill_and_draw() -> void:
	_view_ui.disabled = _node.texture_uuid.empty()
	_view_ui.pressed = _node.texture_view

func _texture_ui_fill_and_draw() -> void:
	var texture = null
	if not _node.is_actor_empty_object():
		texture = _node.actor.resource_by_uuid(_node.texture_uuid, false)
	_texture_ui.texture = texture
	_texture_ui.visible = _node.texture_view

func _sentences_draw_view() -> void:
	_sentences_clear()
	_sentences_draw()

func _sentences_clear() -> void:
	for child in get_children():
		if child is DialoguePanelSentence:
			remove_child(child)
			child.queue_free()

func _sentences_draw() -> void:
	for index in range(_node.sentences.size()):
		_sentence_draw(_node.sentences[index])

func _sentence_draw(sentence: Dictionary) -> void:
	var sentence_ui = PanelSentence.instance()
	add_child(sentence_ui)
	sentence_ui.set_data(_group, sentence, _node, _dialogue, _data)

func update_slots_draw() -> void:
	_slots_draw()

func _slots_draw() -> void:
	var children = get_children()
	for index in range(children.size()):
		var child = children[index]
		if index == 0:
			set_slot(child.get_index(), true, 0, Color.white, false, 0, Color.white)
		elif child is DialoguePanelSentence:
			set_slot(child.get_index(), false, 0, Color.white, true, 0, Color.white)
		else:
			set_slot(child.get_index(), false, 0, Color.white, false, 0, Color.white)

func slot_index_of_selected_sentence() -> int:
	var sentence = _node.selected_sentence()
	for child in get_children():
		if child is DialoguePanelSentence:
			if sentence == child.sentence():
				return child.get_index()
	return -1
