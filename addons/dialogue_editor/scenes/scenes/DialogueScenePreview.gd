extends MarginContainer

var _scale_factor = 1
var _loaded_scene
var _drag = false

func _ready():
	var ref_rect = ReferenceRect.new()
	ref_rect.border_color = Color.white
	ref_rect.editor_only = false
	ref_rect.anchor_right  = 1
	ref_rect.anchor_bottom = 1
	var LoadedScene = load("res://addons/dialogue_editor/default/DialogueActorLeft.tscn")
	_loaded_scene = LoadedScene.instance() as CanvasLayer
	_loaded_scene.add_child(ref_rect)
	add_child(_loaded_scene)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event.button_index == BUTTON_WHEEL_UP):
			_scale_factor = 1.01
		elif (event.button_index == BUTTON_WHEEL_DOWN):
			_scale_factor = 0.99
		elif event.button_index == BUTTON_MIDDLE:
			if event.pressed:
				_drag = true
			else:
				_drag = false
		_scale_transform(event.position)
	if event is InputEventMouseMotion and _drag:
		_drag_transform(event.relative)

func _scale_transform(position: Vector2) -> void:
	var offset_start = _loaded_scene.transform.xform_inv(Vector2(position))
	var transform_end = _loaded_scene.transform.scaled(Vector2(_scale_factor, _scale_factor))
	var offset_end = transform_end.xform_inv(Vector2(position))
	var offset = Vector2(offset_end.x - offset_start.x, offset_end.y - offset_start.y)
	var origin = transform_end.origin
	transform_end.origin = Vector2(origin.x - offset.x, origin.y - offset.y)
	_loaded_scene.set_transform(transform_end)

func _drag_transform(offset: Vector2) -> void:
	var transform = _loaded_scene.transform.translated(offset)
	_loaded_scene.set_transform(transform)
