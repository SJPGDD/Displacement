extends Polygon2D

signal selected(thing, type)
signal deselected

enum SelectionType {
	FACILITY, VECTOR
}

var current_selection
var selection_type

func select_facility(facility):
	if _already_selected(facility, SelectionType.FACILITY):
		_deselect(facility)
	else:
		_select(facility, SelectionType.FACILITY, facility.rect_position)

func select_tile_at_mouse(mp):
	var terrain = $".."
	var map_mp = terrain.world_to_map(mp)
	var tile = terrain.get_cellv(map_mp)
	if tile == terrain.tile_set.find_tile_by_name("TerrainBlockedTile"):
		if _already_selected(map_mp, SelectionType.VECTOR):
			_deselect(map_mp)
		else:
			_select(map_mp, SelectionType.VECTOR, terrain.map_to_world(map_mp))

func _already_selected(thing, type):
	if selection_type != type: return false
	return current_selection == thing

func _select(thing, type, thing_position):
	current_selection = thing
	selection_type = type
	position = thing_position
	visible = true
	$Breathing.play("Breathe")
	emit_signal("selected", thing, type)

func _deselect(thing):
	current_selection = null
	visible = false
	emit_signal("deselected")