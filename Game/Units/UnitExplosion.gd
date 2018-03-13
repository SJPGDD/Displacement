extends Particles2D

const EXPIRE_TIME = 0.2

var controller
var time

func _ready():
	emitting = true
	$Sparks.emitting = true

func _process(delta):
	time += delta
	if time > EXPIRE_TIME:
		emitting = false
		$Sparks.emitting = false
		queue_free()

func setup(controller, pos):
	self.controller = controller
	if controller == 0:
		process_material.color = Color(0, 1, 1)
	else:
		process_material.color = Color(1, 0, 1)
	position = pos
	time = 0
	return self