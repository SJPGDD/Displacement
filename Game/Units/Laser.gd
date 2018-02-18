extends Line2D

func _process(delta):
	queue_free()

func setup(from, to):
	points[1] = to - from
	return self