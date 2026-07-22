class_name CollectorView
extends Node2D

## Draws the chosen collector on its pad with Godot 2D primitives.
##
## Every dimension comes from the collector definition, so the three options
## differ in scale and outline without this script knowing their identifiers.

const PAD_COLOR: Color = Color(0.071, 0.086, 0.114, 0.9)
const PAD_EDGE_COLOR: Color = Color(0.239, 0.302, 0.373)
const BODY_LIGHT: Color = Color(0.494, 0.553, 0.627)
const BODY_MID: Color = Color(0.365, 0.42, 0.494)
const BODY_DARK: Color = Color(0.243, 0.286, 0.353)
const HOPPER_COLOR: Color = Color(0.365, 0.416, 0.494)
const HOPPER_SHADE: Color = Color(0.243, 0.286, 0.353)
const CAP_COLOR: Color = Color(0.573, 0.631, 0.702)
const ACCENT_COLOR: Color = Color(0.957, 0.659, 0.267)
const LEG_COLOR: Color = Color(0.196, 0.231, 0.29)
const ELLIPSE_SQUASH: float = 0.42
const BARREL_STRIPS: int = 18
## Fraction across the barrel where the light falls, matching the machine art.
const BARREL_HIGHLIGHT: float = 0.3
const ELLIPSE_STEPS: int = 28

var _definition: CollectorDefinition = null
var _pad_center: Vector2 = Vector2.ZERO
var _pad_size: Vector2 = Vector2(2.0, 2.0)
var _inlet: Vector3 = Vector3.ZERO


func configure(network: DuctNetworkDefinition) -> void:
	_pad_center = network.collector_pad_center
	_pad_size = network.collector_pad_size
	_inlet = network.collector_inlet
	queue_redraw()


## Passing null clears the collector, which is what an empty proposal shows.
func show_collector(definition: CollectorDefinition) -> void:
	_definition = definition
	queue_redraw()


## The collector currently on the pad, or null when none is chosen.
func current_collector() -> CollectorDefinition:
	return _definition


func _draw() -> void:
	_draw_pad()
	if _definition == null:
		return

	var base: Vector2 = Iso.to_screen(_pad_center)
	var radius: float = _definition.body_radius_px
	var legs: float = _definition.leg_height_px
	var hopper: float = _definition.hopper_height_px
	var body: float = _definition.body_height_px

	var hopper_bottom: float = base.y - legs
	var body_bottom: float = hopper_bottom - hopper
	var body_top: float = body_bottom - body

	_draw_legs(base, radius, legs)

	# Cone hopper narrowing to the discharge, drawn first so the barrel sits on it.
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(base.x - radius, body_bottom),
			Vector2(base.x + radius, body_bottom),
			Vector2(base.x + radius * 0.2, hopper_bottom),
			Vector2(base.x - radius * 0.2, hopper_bottom),
		]),
		HOPPER_COLOR
	)
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(base.x, body_bottom),
			Vector2(base.x + radius, body_bottom),
			Vector2(base.x + radius * 0.2, hopper_bottom),
			Vector2(base.x, hopper_bottom),
		]),
		HOPPER_SHADE
	)
	_draw_ellipse(Vector2(base.x, hopper_bottom), radius * 0.2, CAP_COLOR)

	# Barrel as a shaded cylinder rather than flat bands.
	for strip: int in range(BARREL_STRIPS):
		var left_edge: float = float(strip) / float(BARREL_STRIPS)
		var right_edge: float = float(strip + 1) / float(BARREL_STRIPS)
		draw_rect(
			Rect2(
				base.x - radius + radius * 2.0 * left_edge,
				body_top,
				radius * 2.0 * (right_edge - left_edge) + 0.5,
				body_bottom - body_top
			),
			_barrel_color((left_edge + right_edge) * 0.5)
		)

	# Rounded bottom rim, then the top cap.
	_draw_ellipse(Vector2(base.x, body_bottom), radius, BODY_DARK)
	_draw_ellipse(Vector2(base.x, body_top), radius, CAP_COLOR)

	_draw_inlet_stub(base, radius, body_bottom, body_top)


func _draw_pad() -> void:
	var half: Vector2 = _pad_size * 0.5
	var corners: PackedVector2Array = PackedVector2Array([
		Iso.to_screen(_pad_center + Vector2(-half.x, -half.y)),
		Iso.to_screen(_pad_center + Vector2(half.x, -half.y)),
		Iso.to_screen(_pad_center + Vector2(half.x, half.y)),
		Iso.to_screen(_pad_center + Vector2(-half.x, half.y)),
	])
	draw_colored_polygon(corners, PAD_COLOR)

	var closed: PackedVector2Array = corners.duplicate()
	closed.append(corners[0])
	draw_polyline(closed, PAD_EDGE_COLOR, 2.0)


func _draw_legs(base: Vector2, radius: float, legs: float) -> void:
	for offset: float in [-radius * 0.72, radius * 0.72]:
		draw_line(
			Vector2(base.x + offset, base.y - legs - 2.0),
			Vector2(base.x + offset * 0.9, base.y),
			LEG_COLOR,
			5.0
		)


## Flanged stub where the main enters the barrel.
func _draw_inlet_stub(base: Vector2, radius: float, body_bottom: float, body_top: float) -> void:
	var inlet_screen: Vector2 = Iso.to_screen(Vector2(_inlet.x, _inlet.y)) - Vector2(0.0, _inlet.z)
	var stub_start: Vector2 = Vector2(base.x + radius * 0.55, inlet_screen.y)
	draw_line(stub_start, inlet_screen, BODY_DARK, 18.0)
	draw_line(stub_start, inlet_screen, BODY_MID, 13.0)
	draw_circle(inlet_screen, 9.5, BODY_LIGHT)
	draw_arc(inlet_screen, 9.5, 0.0, TAU, 20, ACCENT_COLOR, 1.5, true)


## Left-lit barrel shading, `across` running 0 at the left edge to 1 at the right.
func _barrel_color(across: float) -> Color:
	if across < BARREL_HIGHLIGHT:
		return BODY_MID.lerp(BODY_LIGHT, across / BARREL_HIGHLIGHT)
	return BODY_LIGHT.lerp(BODY_DARK, (across - BARREL_HIGHLIGHT) / (1.0 - BARREL_HIGHLIGHT))


func _draw_ellipse(center: Vector2, radius: float, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	for step: int in range(ELLIPSE_STEPS):
		var angle: float = TAU * float(step) / float(ELLIPSE_STEPS)
		points.append(
			center + Vector2(cos(angle) * radius, sin(angle) * radius * ELLIPSE_SQUASH)
		)
	draw_colored_polygon(points, color)
