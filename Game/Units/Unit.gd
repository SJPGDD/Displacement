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
var target_unit

func _ready():
	_configure_colliders()

func _process(delta):
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
		UnitState.ATTACKING: pass
		UnitState.DYING: pass

func _configure_colliders():
	set_collision_layer_bit(controller, true)
	set_collision_mask_bit(controller, false)
	$SightRadius.set_collision_mask_bit(controller, false)
	sight_range = $SightRadius/Collider.shape.radius

func _spotted_opposing_unit(unit):
	if target_unit == null or _range(unit) < _range(target_unit):
		target_unit = unit
	unit_state = UnitState.SEEKING

func _direction(unit):
	return (unit.position - position).normalized()

func _range(unit):
	return position.distance_to(unit.position)