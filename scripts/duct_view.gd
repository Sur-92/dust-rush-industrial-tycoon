class_name DuctView
extends Node2D

## Draws the ductwork described by `DuctRunDefinition` data.
##
## This script projects waypoints and shades pipe; it never decides where a
## duct goes, what diameter it is, or which machine it serves. It reads no
## machine, route, or collector identifier.

## Drawn pipe width per inch of duct diameter, so 4, 5, 6, 7 and 9 inch runs
## are visibly different thicknesses.
const PIXELS_PER_INCH: float = 2.4
const BEND_SAMPLES: int = 8

const PIPE_LIGHT: Color = Color(0.729, 0.776, 0.827)
const PIPE_MID: Color = Color(0.529, 0.584, 0.651)
const PIPE_DARK: Color = Color(0.271, 0.318, 0.384)
const HIGHLIGHT_LIGHT: Color = Color(0.988, 0.855, 0.612)
const HIGHLIGHT_MID: Color = Color(0.945, 0.694, 0.325)
const HIGHLIGHT_DARK: Color = Color(0.545, 0.361, 0.129)
const COLLAR_COLOR: Color = Color(0.373, 0.427, 0.494)
const COLLAR_EDGE: Color = Color(0.663, 0.706, 0.761)
## Soft floor shadow that grounds the overhead runs so they do not float.
const SHADOW_COLOR: Color = Color(0.0, 0.0, 0.0, 0.13)
const SHADOW_WIDTH_SCALE: float = 0.85

var _runs: Array[DuctRunDefinition] = []
var _highlighted_run_ids: Array[StringName] = []
var _collars: Array[Vector3] = []
var _collar_diameters: PackedFloat64Array = PackedFloat64Array()


## `runs` are drawn back to front in the order given. `highlighted_run_ids`
## marks the branch belonging to the machine the player has selected.
func show_runs(runs: Array[DuctRunDefinition], highlighted_run_ids: Array[StringName]) -> void:
	_runs = runs
	_highlighted_run_ids = highlighted_run_ids
	queue_redraw()


## Fittings drawn as collars where airflow merges and the duct steps up.
func show_collars(positions: Array[Vector3], diameters: PackedFloat64Array) -> void:
	_collars = positions
	_collar_diameters = diameters
	queue_redraw()


## Runs currently on screen, so tests and callers can inspect what is drawn
## without reaching into this node's internals.
func active_runs() -> Array[DuctRunDefinition]:
	return _runs


func has_run(run_id: StringName) -> bool:
	for run: DuctRunDefinition in _runs:
		if run.run_id == run_id:
			return true
	return false


func highlighted_run_ids() -> Array[StringName]:
	return _highlighted_run_ids


func clear() -> void:
	_runs = []
	_highlighted_run_ids = []
	_collars = []
	_collar_diameters = PackedFloat64Array()
	queue_redraw()


func _draw() -> void:
	# Floor shadows first, so every pipe is grounded before it is drawn.
	for run: DuctRunDefinition in _runs:
		_draw_shadow(run)

	for run: DuctRunDefinition in _runs:
		_draw_run(run, _highlighted_run_ids.has(run.run_id))

	for index: int in range(_collars.size()):
		if index >= _collar_diameters.size():
			break
		_draw_collar(_collars[index], _collar_diameters[index])


func _draw_run(run: DuctRunDefinition, highlighted: bool) -> void:
	var points: PackedVector2Array = _screen_points(run)
	if points.size() < 2:
		return

	var width: float = run.diameter_inches * PIXELS_PER_INCH
	var light: Color = HIGHLIGHT_LIGHT if highlighted else PIPE_LIGHT
	var mid: Color = HIGHLIGHT_MID if highlighted else PIPE_MID
	var dark: Color = HIGHLIGHT_DARK if highlighted else PIPE_DARK

	# Underside first, then the barrel, then a top highlight, so the pipe reads
	# as a cylinder rather than a flat line.
	_draw_pipe_layer(points, width + 3.0, dark, Vector2(0.0, width * 0.16))
	_draw_pipe_layer(points, width, mid, Vector2.ZERO)
	_draw_pipe_layer(points, width * 0.34, light, Vector2(0.0, -width * 0.24))


func _draw_pipe_layer(
	points: PackedVector2Array, width: float, color: Color, offset: Vector2
) -> void:
	var shifted: PackedVector2Array = PackedVector2Array()
	for point: Vector2 in points:
		shifted.append(point + offset)

	draw_polyline(shifted, color, width, true)

	# Round off the joints so corners do not show wedge gaps.
	for index: int in range(1, shifted.size() - 1):
		draw_circle(shifted[index], width * 0.5, color)


## Projects a run straight down onto the floor and draws it as a soft shadow,
## which anchors the overhead pipe above the spot it covers.
func _draw_shadow(run: DuctRunDefinition) -> void:
	var path: PackedVector3Array = run.waypoints
	if run.bend_radius > 0.0:
		path = _rounded_path(path, run.bend_radius)

	var floor_points: PackedVector2Array = PackedVector2Array()
	for point: Vector3 in path:
		floor_points.append(Iso.to_screen(Vector2(point.x, point.y)))
	if floor_points.size() < 2:
		return

	var width: float = run.diameter_inches * PIXELS_PER_INCH * SHADOW_WIDTH_SCALE
	draw_polyline(floor_points, SHADOW_COLOR, width, true)
	for index: int in range(1, floor_points.size() - 1):
		draw_circle(floor_points[index], width * 0.5, SHADOW_COLOR)


func _draw_collar(position: Vector3, diameter_inches: float) -> void:
	var center: Vector2 = _project(position)
	var radius: float = diameter_inches * PIXELS_PER_INCH * 0.56
	draw_circle(center, radius, COLLAR_COLOR)
	draw_arc(center, radius, 0.0, TAU, 24, COLLAR_EDGE, 1.0, true)


func _screen_points(run: DuctRunDefinition) -> PackedVector2Array:
	var path: PackedVector3Array = run.waypoints
	if run.bend_radius > 0.0:
		path = _rounded_path(path, run.bend_radius)

	var points: PackedVector2Array = PackedVector2Array()
	for point: Vector3 in path:
		points.append(_project(point))
	return points


## Tile x/y project isometrically; z lifts the point straight up the screen.
func _project(point: Vector3) -> Vector2:
	return Iso.to_screen(Vector2(point.x, point.y)) - Vector2(0.0, point.z)


## Replaces each sharp corner with a quadratic arc, giving Sweeping routes
## their broad bends while Direct routes keep their mitred elbow.
func _rounded_path(points: PackedVector3Array, radius: float) -> PackedVector3Array:
	if points.size() < 3:
		return points

	var result: PackedVector3Array = PackedVector3Array()
	result.append(points[0])

	for index: int in range(1, points.size() - 1):
		var before: Vector3 = points[index - 1]
		var here: Vector3 = points[index]
		var after: Vector3 = points[index + 1]

		var incoming: Vector3 = here - before
		var outgoing: Vector3 = after - here
		if incoming.length() < 0.0001 or outgoing.length() < 0.0001:
			result.append(here)
			continue

		var trim: float = minf(radius, minf(incoming.length(), outgoing.length()) * 0.45)
		var start: Vector3 = here - incoming.normalized() * trim
		var end: Vector3 = here + outgoing.normalized() * trim

		result.append(start)
		for step: int in range(1, BEND_SAMPLES):
			var weight: float = float(step) / float(BEND_SAMPLES)
			result.append(
				start.lerp(here, weight).lerp(here.lerp(end, weight), weight)
			)
		result.append(end)

	result.append(points[points.size() - 1])
	return result
