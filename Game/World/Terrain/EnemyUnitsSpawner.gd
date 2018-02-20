extends Node2D

const SPAWNING_HELPER = preload("SpawningHelper.gd")

export(PoolStringArray) var spawns_units

onready var spawnable_units = _load_units()

func _process(delta):
	if randf() < 0.02:
		var helper = SPAWNING_HELPER.new(spawnable_units[0], 1, Vector2(-1, 0).rotated(rand_range(-.5, .5)))
		helper.position = Vector2(300, rand_range(-200, 200))
		add_child(helper)

func _load_units():
	var units = []
	for unit in spawns_units:
		units.append(load("res://Game/Units/%s.tscn" % unit))
	return units