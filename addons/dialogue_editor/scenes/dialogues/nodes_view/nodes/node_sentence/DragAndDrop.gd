# Plugin implementation 
# @author Vladimir Petrenko
tool
extends PanelContainer

var _icon_size = Vector2(20, 20)
var _texture_size = Vector2(150, 150)

func _ready() -> void:
	$HBox/View.visible = false
	_init_connections()

func _init_connections() -> void:
	$HBox/View.connect("toggled", self, "_on_texture_toggled")

func can_drop_data(position, data) -> bool:
	return true

func drop_data(position, data) -> void:
	var file_paths = data["files"]
	for path in file_paths:
		var resource = load(path)
		if resource and resource is DialogueActor:
			if $HBox/Label:
				$HBox/Label.queue_free()
			$HBox/Name.text = resource.name
			$HBox/Texture.texture = _resize_texture(resource.texture, _icon_size)
			var texture = get_parent().get_node("Center/Texture")
			texture.texture = _resize_texture(resource.texture, _texture_size)
			texture.visible = $HBox/View.is_pressed()
			$HBox/View.visible = true
			get_parent().rect_size = Vector2.ZERO

func _on_texture_toggled(button_pressed: bool) -> void:
	get_parent().get_node("Center/Texture").visible = button_pressed
	get_parent().rect_size = Vector2.ZERO

func _resize_texture(t: Texture, size: Vector2):
	var image = t.get_data()
	if size.x > 0 && size.y > 0:
		image.resize(size.x, size.y)
	var itex = ImageTexture.new()
	itex.create_from_image(image)
	return itex
