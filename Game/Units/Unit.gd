extends KinematicBody2D

const Laser = preload("res://Game/Units/Laser.tscn")
const PlayerUnitColor = preload("res://Game/Units/PlayerUnitColor.tres")
const EnemyUnitColor = preload("res://Game/Units/EnemyUnitColor.tres")

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

onready var extras = $"../../Extras"

var health = 0
var unit_state = UnitState.MARCHING
var cooldown_timer = 0
var target_units = []
var target_unit

func _ready():
	_configure_colliders()
	_configure_appearance()
	health = starting_health

func _process(delta):
	if unit_state != UnitState.DYING:
		_refresh_target_unit()
		_execute_AI_state_machine(delta)
		_check_death()

func take_damage(attack_damage, crit_chance):
	health -= attack_damage * (1 + int(randf() < crit_chance))

func _configure_colliders():
	set_collision_layer_bit(controller, true)
	set_collision_mask_bit(controller, false)
	$SightRadius.set_collision_mask_bit(controller, false)
	sight_range = $SightRadius/Collider.shape.radius

func _configure_appearance():
	if controller == ControllerType.PLAYER:
		$Texture.material = PlayerUnitColor
	else:
		$Texture.material = EnemyUnitColor

func _refresh_target_unit():
	if target_units.empty(): target_unit = null
	for unit in target_units:
		if _range(unit) < _range(target_unit):
			target_unit = unit
	if _invalid_target(target_unit):
		unit_state = UnitState.MARCHING

func _execute_AI_state_machine(delta):
	match unit_state:
		UnitState.MARCHING: _march(delta)
		UnitState.SEEKING: _seek()
		UnitState.ATTACKING: _attack(delta)
		UnitState.DYING: pass

func _check_death():
	if health <= 0 and unit_state != UnitState.DYING: 
		unit_state = UnitState.DYING
		$DeathAnimation.play("Death")

func _march(delta):
	var collision = move_and_collide(direction * movement_speed * delta)
	if collision != null and collision.collider.is_in_group("Terrain"):
		direction = direction.reflect(collision.normal.rotated(PI / 2)).rotated(rand_range(-0.5, 0.5))

func _seek():
	move_and_slide(_direction(target_unit) * movement_speed)
	var unit_range = _range(target_unit)
	if unit_range > sight_range:
		unit_state = UnitState.MARCHING
	elif unit_range < attack_range:
		unit_state = UnitState.ATTACKING

func _attack(delta):
	cooldown_timer -= delta
	if cooldown_timer <= 0:
		cooldown_timer = attack_cooldown
		target_unit.take_damage(attack_damage, crit_chance)
		extras.add_child(Laser.instance().setup(controller, position, target_unit.position))

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
	if _invalid_target(unit): return INF
	return position.distance_to(unit.position)

func _invalid_target(unit):
	return unit == null or !weakref(unit).get_ref() or !unit.is_in_group("Unit") or unit.unit_state == UnitState.DYING