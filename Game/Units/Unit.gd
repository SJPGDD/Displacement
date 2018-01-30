extends KinematicBody2D

enum ControllerType {
	PLAYER, ENEMY
}

enum UnitState {
	MARCHING, SEEKING, ATTACKING, DYING
}

export(int) var starting_health
export(int) var movement_speed
export(int) var attack_range
export(float) var attack_cooldown
export(int) var attack_damage
export(float) var crit_chance
export(int) var spawn_time
export(int) var spawn_count
export(int) var sight_range
export(ControllerType) var controller
export(Vector2) var direction

var health = starting_health
var unit_state = UnitState.MARCHING
var target_units = []
var target_unit

func _ready():
	_configure_colliders()

func _process(delta):
	_refresh_target_unit()
	_execute_AI_state_machine(delta)

func _configure_colliders():
	set_collision_layer_bit(controller, true)
	set_collision_mask_bit(controller, false)
	$SightRadius.set_collision_mask_bit(controller, false)
	sight_range = $SightRadius/Collider.shape.radius

func _refresh_target_unit():
	if target_units.empty(): target_unit = INF
	for unit in target_units:
		if _range(unit) < _range(target_unit):
			target_unit = unit

func _execute_AI_state_machine(delta):
	match unit_state:
		UnitState.MARCHING:
			move_and_slide(direction * movement_speed)
		UnitState.SEEKING:
			move_and_slide(_direction(target_unit) * movement_speed)
			var unit_range = _range(target_unit)
			if unit_range > sight_range:
				unit_state = UnitState.MARCHING
			elif unit_range < attack_range:
				unit_state = UnitState.ATTACKING
		UnitState.ATTACKING:
			pass
		UnitState.DYING:
			pass

func _spotted_opposing_unit(unit):
	target_units.append(unit)
	unit_state = UnitState.SEEKING

func _unspotted_opposing_unit(unit):
	target_units.remove(target_units.find(unit))
	if target_units.size() == 0:
		unit_state = UnitState.MARCHING

func _direction(unit):
	return (unit.position - position).normalized()

func _range(unit):
	if unit == INF: return INF
	return position.distance_to(unit.position)