extends ScrollContainer

var _scale_factor = 1
var _loaded_scene
var _drag = false

func _ready():
	var LoadedScene = load("res://addons/dialogue_editor/default/DialogueActorLeft.tscn")
	_loaded_scene = LoadedScene.instance() as Control
	add_child(_loaded_scene)

#func _input(event: InputEvent) -> void:
#	if event is InputEventMouseButton:
#		if (event.button_index == BUTTON_WHEEL_UP):
#			_scale_factor = 1.01
#		elif (event.button_index == BUTTON_WHEEL_DOWN):
#			_scale_factor = 0.99
#		elif event.button_index == BUTTON_MIDDLE:
#			_drag = event.pressed
#		_scale_transform(event.position)
#	if event is InputEventMouseMotion and _drag:
#		var scale = _loaded_scene.transform.get_scale()
#		var relative = Vector2(event.relative.x * scale.x, event.relative.y * scale.y)
#		_drag_transform(event.relative)
#
#func _scale_transform(position: Vector2) -> void:
#	var offset_start = _loaded_scene.transform.xform_inv(Vector2(position))
#	var transform_end = _loaded_scene.transform.scaled(Vector2(_scale_factor, _scale_factor))
#	var offset_end = transform_end.xform_inv(Vector2(position))
#	var offset = Vector2(offset_end.x - offset_start.x, offset_end.y - offset_start.y)
#	var origin = transform_end.origin
#	transform_end.origin = Vector2(origin.x - offset.x, origin.y - offset.y)
#	_loaded_scene.set_transform(transform_end)
#
#func _drag_transform(offset: Vector2) -> void:
#	var transform = _loaded_scene.transform.translated(offset)
#	_loaded_scene.set_transform(transform)
