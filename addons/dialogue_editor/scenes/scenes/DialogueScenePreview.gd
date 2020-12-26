extends ViewportContainer

var zoom = 1.0
var size = Vector2(800, 600)

func _ready() -> void:
	$Viewport.set_size(size)
	var DialogueActorDialog = load("res://addons/dialogue_editor/default/DialogueActorLeft.tscn")
	var scene = DialogueActorDialog.instance()
	$Viewport.add_child(scene)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if (event.button_index == BUTTON_WHEEL_UP):
			print("wheel up (event)")
			zoom += 0.1
			$Viewport.set_size_override(true, size * zoom)
		if (event.button_index == BUTTON_WHEEL_DOWN):
			print("wheel down (event)")
			zoom -= 0.1
			$Viewport.set_size_override(true, size * zoom)
