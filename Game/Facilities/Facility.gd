extends TextureButton

export(PoolStringArray) var spawns_units

onready var spawnable_units = _load_units()

func _ready():
	_register_with_selector()

func _process(delta):
	if pressed and delta - int(delta) < 0.05:
		var unit = spawnable_units[0].instance()
		unit.position = rect_position + Vector2(75, 25)
		unit.direction = Vector2(1, 0).rotated(rand_range(-0.5, 0.5))
		unit.controller = 0
		
		$"../../PlayerUnits".add_child(unit)

func get_rect():
	return Rect2(rect_position, rect_size * rect_scale)

func _load_units():
	var units = []
	for unit in spawns_units:
		units.append(load("res://Game/Units/%s.tscn" % unit))
	return units

func _register_with_selector():
	connect("button_down", $"../../SelectionController", "select_facility", [self])