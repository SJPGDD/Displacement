extends Node2D

var latency = 5 #frame delay
var threshold = 100 #start of using frame delay
var update_phase = 0
var player_units
var enemy_units

func _process(delta):
	_get_units()
	_target_refresh_phase()
	_unit_update_phase(delta)

func _get_units():
	player_units = $PlayerUnits.get_children()
	enemy_units = $EnemyUnits.get_children()

func _target_refresh_phase():
	var phase = _get_update_phase()
	var p_refrs = _split_range(phase, latency, player_units, threshold)
	var e_refrs = _split_range(phase, latency, enemy_units, threshold)
	
	_execute_target_refresh(player_units, enemy_units, p_refrs)
	_execute_target_refresh(enemy_units, player_units, e_refrs)

func _execute_target_refresh(side, opp, refrs):
	var cur_unit
	var cur_dist
	var min_dist
	var min_dist_o
	
	for i in refrs:
		cur_unit = side[i]
		if cur_unit.unit_state == cur_unit.UnitState.DYING: continue
		cur_unit.target_unit = null
		cur_unit.unit_state = cur_unit.UnitState.MARCHING
		min_dist = INF
		for o in opp:
			if o.unit_state == o.UnitState.DYING: continue
			cur_dist = cur_unit.position.distance_to(o.position)
			if cur_dist < min_dist:
				min_dist = cur_dist
				min_dist_o = o
		if min_dist <= cur_unit.sight_range:
			cur_unit.target_unit = min_dist_o
			if min_dist <= cur_unit.attack_range:
				cur_unit.unit_state = cur_unit.UnitState.ATTACKING
			else:
				cur_unit.unit_state = cur_unit.UnitState.ATTACKING

func _unit_update_phase(delta):
	_execute_unit_update(player_units, delta)
	_execute_unit_update(enemy_units, delta)

func _execute_unit_update(units, delta):
	for u in units:
		if u.controller == u.ControllerType.PLAYER && u.unit_state != u.UnitState.DYING:
			if u.rally_point.visible:
				u.unit_state = u.UnitState.RALLYING
			elif u.unit_state == u.UnitState.RALLYING:
				u.unit_state = u.UnitState.MARCHING
		match u.unit_state:
			u.UnitState.MARCHING: u.march(delta)
			u.UnitState.SEEKING: u.seek()
			u.UnitState.ATTACKING: u.attack(delta)
			u.UnitState.DYING: u.die()
			u.UnitState.RALLYING: 
				if !u.rally(delta) && u.target_unit != null:
					u.attack(delta)

func _get_update_phase():
	var temp = update_phase
	update_phase += 1
	if update_phase > latency:
		update_phase = 1
	return update_phase

func _split_range(section, count, array, threshold):
	var size = array.size()
	if size < threshold: return range(0, size)
	var idxs = []
	idxs.resize(count + 1)
	idxs[0] = 0
	idxs[count] = size
	for i in range(1, count):
		idxs[i] = i * (size / count)
	return range(idxs[section-1], idxs[section])