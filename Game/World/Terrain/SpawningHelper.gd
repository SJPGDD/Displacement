extends Node2D

const SPAWN_INTERVAL = 0.5

var unit_type
var time_until_spawn
var num_to_spawn
var controller
var direction

func _process(delta):
	_run_spawner_timer(delta)

func _init(unit_type, controller, direction):
	self.unit_type = unit_type
	_parse_template_unit()
	self.controller = controller
	self.direction = direction

func _run_spawner_timer(delta):
	time_until_spawn -= delta
	if time_until_spawn <= 0:
		_spawn()
		time_until_spawn = SPAWN_INTERVAL
	if num_to_spawn == 0:
		queue_free()

func _spawn():
	var unit = unit_type.instance()
	unit.position = position
	unit.controller = controller
	unit.direction = direction
	get_parent().add_child(unit)
	num_to_spawn -= 1

func _parse_template_unit():
	var template_unit = unit_type.instance()
	time_until_spawn = template_unit.spawn_time
	num_to_spawn = template_unit.spawn_count