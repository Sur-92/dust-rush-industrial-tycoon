class_name DuctRunDefinition
extends Resource

## One constant-diameter run of duct, described declaratively.
##
## Waypoints are stored as Vector3: `x` and `y` are shop tile coordinates and
## `z` is elevation in pixels above the floor. The renderer projects these; it
## never decides where a duct goes and never inspects a machine or route id.

@export var run_id: StringName = &""
@export var diameter_inches: float = 4.0
## Tile-space path. Vector3(tile_x, tile_y, elevation_px).
@export var waypoints: PackedVector3Array = PackedVector3Array()
## Corner rounding in tile units. 0 draws a sharp mitre, larger draws a broad bend.
@export var bend_radius: float = 0.0


func point_count() -> int:
	return waypoints.size()


## Path length in tile units, ignoring elevation, used to compare route lengths.
func plan_length_tiles() -> float:
	var total: float = 0.0
	for index: int in range(1, waypoints.size()):
		var from_point: Vector3 = waypoints[index - 1]
		var to_point: Vector3 = waypoints[index]
		total += Vector2(to_point.x - from_point.x, to_point.y - from_point.y).length()
	return total


## Number of direction changes in the plan view, so a sharp route can be
## distinguished from a gently bent one without reading identifiers.
func corner_count() -> int:
	if waypoints.size() < 3:
		return 0

	var corners: int = 0
	for index: int in range(1, waypoints.size() - 1):
		var before: Vector3 = waypoints[index - 1]
		var here: Vector3 = waypoints[index]
		var after: Vector3 = waypoints[index + 1]
		var incoming: Vector2 = Vector2(here.x - before.x, here.y - before.y)
		var outgoing: Vector2 = Vector2(after.x - here.x, after.y - here.y)
		if incoming.length() < 0.001 or outgoing.length() < 0.001:
			continue
		if absf(incoming.normalized().dot(outgoing.normalized()) - 1.0) > 0.001:
			corners += 1
	return corners
