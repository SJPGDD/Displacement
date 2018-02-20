extends TextureButton

const ZOOM_FACTOR = 0.1
const MIN_ZOOM = 0.5
const MAX_ZOOM = 2.0
const MAP_START_POSITION = Vector2(300, 275)

enum Zoom {
	IN = 1,
	OUT = -1
}

onready var map = get_parent()
onready var cam = $Camera

var is_panning = false
var target_position = MAP_START_POSITION
var target_zoom = Vector2(1, 1)

func _ready():
	_reset_map()

func _process(delta):
	cam.position = _lerp_vector(cam.position, target_position, 0.2)
	cam.zoom = _lerp_vector(cam.zoom, target_zoom, 0.2)

func _begin_pan():
	is_panning = true

func _end_pan():
	is_panning = false

func _pan_map(displacement):
	target_position -= displacement

func _zoom_map(direction):
	target_zoom = Vector2(1, 1) * clamp(
		target_zoom.x - ZOOM_FACTOR * direction, MIN_ZOOM, MAX_ZOOM
	)

func _reset_map():
	target_position = MAP_START_POSITION
	target_zoom = Vector2(1.2, 1.2)

func _lerp_vector(from, to, factor):
	return Vector2(lerp(from.x, to.x, factor), lerp(from.y, to.y, factor))

func _input(event):
	match event.get_class():
		"InputEventMouseButton":
			if event.button_index == BUTTON_WHEEL_UP:
				_zoom_map(Zoom.IN)
			elif event.button_index == BUTTON_WHEEL_DOWN:
				_zoom_map(Zoom.OUT)
			elif event.button_index == BUTTON_LEFT:
				if event.doubleclick:
					_reset_map()
				elif event.pressed:
					var mp = $"..".get_local_mouse_position()
					if $"../Facilities".at(mp) == null:
						$"../SelectionController".select_tile_at_mouse(mp)
		"InputEventMouseMotion":
			if is_panning:
				_pan_map(event.relative)