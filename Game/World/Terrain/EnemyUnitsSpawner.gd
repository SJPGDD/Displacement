extends Node2D

const SpawningHelper = preload("SpawningHelper.gd")

export(PoolStringArray) var spawns_units

onready var spawnable_units = _load_units()
onready var spawners = $"../../Spawners"

func _process(delta):
	if randf() < 0.02:
		var helper = SpawningHelper.new(spawnable_units[0], 1, self, Vector2(-1, 0).rotated(rand_range(-.5, .5)))
		helper.position = Vector2(500, rand_range(-200, 200))
		spawners.add_child(helper)

func _load_units():
	var units = []
	for unit in spawns_units:
		units.append(load("res://Game/Units/%s.tscn" % unit))
	return units