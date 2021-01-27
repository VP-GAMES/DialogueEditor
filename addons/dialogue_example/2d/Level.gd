extends Node2D

onready var _error_ui = $CanvasError as CanvasLayer

func _ready() -> void:
	if get_tree().get_root().has_node("DialogueManager"):
		_error_ui.queue_free()
