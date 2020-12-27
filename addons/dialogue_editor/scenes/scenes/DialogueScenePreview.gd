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
		var transform = _loaded_scene.transform.scaled(Vector2(_scale_factor, _scale_factor))
		_loaded_scene.set_transform(transform)
	
	if event is InputEventMouseMotion and _drag:
		var transform = _loaded_scene.transform.translated(event.relative)
		_loaded_scene.set_transform(transform)
