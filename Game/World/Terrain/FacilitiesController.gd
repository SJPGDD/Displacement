extends Node2D

func at(facility_position):
	for facility in get_children():
		if facility.get_rect().has_point(facility_position):
			return facility
	return null