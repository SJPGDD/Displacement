extends KinematicBody2D

const Laser = preload("res://Game/Units/Laser.tscn")
const PlayerUnitColor = preload("res://Game/Units/PlayerUnitColor.tres")
const EnemyUnitColor = preload("res://Game/Units/EnemyUnitColor.tres")
const UnitExplosion = preload("res://Game/Units/UnitExplosion.tscn")

enum ControllerType {
	PLAYER, ENEMY
}

enum UnitState {
	MARCHING, SEEKING, ATTACKING, DYING, RALLYING
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

onready var projectiles = $"../../../Projectiles"
onready var rally_point = $"../../../RallyPoint"

var health = 0
var unit_state = UnitState.MARCHING
var cooldown_timer = 0
var target_units = []
var target_unit

func _ready():
	_configure_colliders()
	_configure_appearance()
	health = starting_health

func take_damage(attack_damage, crit_chance):
	health -= attack_damage * (1 + int(randf() < crit_chance))
	_check_death()

func _configure_colliders():
	set_collision_layer_bit(controller, true)
	set_collision_mask_bit(controller, false)

func _configure_appearance():
	if controller == ControllerType.PLAYER:
		$Texture.material = PlayerUnitColor
	else:
		$Texture.material = EnemyUnitColor

func _check_death():
	if health <= 0 and unit_state != UnitState.DYING:
		unit_state = UnitState.DYING

func march(delta):
	var collision = move_and_collide(direction * movement_speed * delta)
	if collision != null and collision.collider.is_in_group("Terrain"):
		direction = direction.reflect(collision.normal.rotated(PI / 2)).rotated(rand_range(-0.5, 0.5))

func rally(delta):
	if !rally_point.visible:
		unit_state = UnitState.MARCHING
	elif position.distance_to(rally_point.position) > 50:
		move_and_slide((rally_point.position - position).normalized() * movement_speed)
		return true
	else: return false

func seek():
	move_and_slide(_direction(target_unit) * movement_speed)

func attack(delta):
	if _invalid_target(target_unit):
		target_unit = null; unit_state = UnitState.MARCHING; return
	
	cooldown_timer -= delta
	if cooldown_timer <= 0:
		cooldown_timer = attack_cooldown
		target_unit.take_damage(attack_damage, crit_chance)
		projectiles.add_child(Laser.instance().setup(controller, position, target_unit.position))

func die():
	if $DeathAnimation.current_animation == "":
		$DeathAnimation.play("Death")
		projectiles.add_child(UnitExplosion.instance().setup(self.controller, position))

func _direction(unit):
	return (unit.position - position).normalized()

func _range(unit):
	if _invalid_target(unit): return INF
	return position.distance_to(unit.position)

func _invalid_target(unit):
	return unit == null or !weakref(unit).get_ref() or !unit.is_in_group("Unit") or unit.unit_state == UnitState.DYING