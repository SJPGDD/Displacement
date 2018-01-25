tool
extends TextureButton

const ZOOM_FACTOR = 0.1
const MIN_ZOOM = 0.5
const MAX_ZOOM = 2.0

const MAP_START_POSITION = Vector2(1280/2, 720/2 - 25)

enum Zoom {
	IN = 1,
	OUT = -1
}

onready var map = get_parent()

var is_panning = false

func _ready():
	_reset_map()

func _begin_pan():
	is_panning = true

func _end_pan():
	is_panning = false

func _pan_map(displacement, scale):
	map.position += displacement

func _zoom_map(direction):
	map.scale.x = clamp(map.scale.x + ZOOM_FACTOR * direction, MIN_ZOOM, MAX_ZOOM)
	map.scale.y = clamp(map.scale.y + ZOOM_FACTOR * direction, MIN_ZOOM, MAX_ZOOM)

func _reset_map():
	map.position = MAP_START_POSITION
	map.scale = Vector2(1, 1)

func _input(event):
	match event.get_class():
		"InputEventMouseButton":
			if event.button_index == BUTTON_WHEEL_UP:
				_zoom_map(Zoom.IN)
			elif event.button_index == BUTTON_WHEEL_DOWN:
				_zoom_map(Zoom.OUT)
			elif event.button_index == BUTTON_LEFT and event.doubleclick:
				_reset_map()
		"InputEventMouseMotion":
			if is_panning:
				_pan_map(event.relative, get_parent().scale)