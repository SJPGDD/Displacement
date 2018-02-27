extends Particles2D

const TRAVEL_TIME = 0.2

var controller
var target
var direction
var distance
var time
var curve_strength

func _ready():
	var velocity = _get_velocity()
	position += velocity.normalized() * 10
	rotation = velocity.angle() - PI

func _process(delta):
	time += delta
	if time < TRAVEL_TIME:
		var velocity = _get_velocity() * delta
		position += velocity
		rotation = velocity.angle() - PI
	else: 
		emitting = false
		if time >= TRAVEL_TIME * 2:
			queue_free()

func setup(controller, from, to):
	self.controller = controller
	if controller == 0:
		modulate = Color(0, 1, 1)
	else:
		modulate = Color(1, 0, 1)
	position = from
	target = to
	direction = (target - position).angle()
	distance = (target - position).length()
	time = 0
	curve_strength = rand_range(2000, -2000)
	return self

func _get_velocity():
	return Vector2(_dx_dt(), _dy_dt()).rotated(direction)

func _dx_dt():
	return distance / TRAVEL_TIME

func _dy_dt():
	return TRAVEL_TIME * curve_strength - 2 * curve_strength * time