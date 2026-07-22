class_name MachineView
extends Node2D

## Placeholder isometric body for one machine on the shop floor.
##
## The view owns presentation only. A click on its silhouette is reported as
## selection intent; the run controller decides which machine is selected and
## hands the resulting state back through `set_selected`.

signal selection_requested(machine_id: StringName)

const PAD_MARGIN: float = 0.18
const LABEL_GAP: float = 12.0

const PAD_COLOR: Color = Color(0.055, 0.071, 0.098, 0.85)
const SELECTED_PAD_COLOR: Color = Color(0.318, 0.224, 0.106, 0.9)
const BODY_TOP_COLOR: Color = Color(0.408, 0.475, 0.573)
const BODY_RIGHT_COLOR: Color = Color(0.271, 0.325, 0.408)
const BODY_LEFT_COLOR: Color = Color(0.192, 0.235, 0.302)
const SELECTED_TOP_COLOR: Color = Color(0.957, 0.659, 0.267)
const SELECTED_RIGHT_COLOR: Color = Color(0.769, 0.502, 0.176)
const SELECTED_LEFT_COLOR: Color = Color(0.541, 0.341, 0.114)
const RING_COLOR: Color = Color(0.957, 0.659, 0.267)
const LABEL_COLOR: Color = Color(0.69, 0.749, 0.82)
const SELECTED_LABEL_COLOR: Color = Color(0.976, 0.788, 0.482)

@export var definition: MachineDefinition
@export var tile_position: Vector2 = Vector2.ZERO
@export var body_tiles: Vector2 = Vector2(2.0, 2.0)
@export var body_height: float = 36.0
@export var topper_offset_tiles: Vector2 = Vector2.ZERO
@export var topper_tiles: Vector2 = Vector2.ZERO
@export var topper_height: float = 0.0

@onready var _name_label: Label = $NameLabel

var _selected: bool = false
var _body_silhouette: PackedVector2Array = PackedVector2Array()
var _topper_silhouette: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	if definition == null:
		push_error("MachineView '%s' has no MachineDefinition assigned." % name)
		set_process_unhandled_input(false)
		return

	position = Iso.to_screen(tile_position)
	_body_silhouette = _silhouette(Vector2.ZERO, body_tiles, 0.0, body_height)
	if _has_topper():
		_topper_silhouette = _silhouette(
			topper_offset_tiles, topper_tiles, body_height, topper_height
		)
	_place_name_label()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event == null:
		return
	if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return

	var local_event := make_input_local(mouse_event) as InputEventMouseButton
	if not contains_point(local_event.position):
		return

	selection_requested.emit(definition.machine_id)
	get_viewport().set_input_as_handled()


func set_selected(value: bool) -> void:
	if _selected == value:
		return
	_selected = value
	_name_label.add_theme_color_override(
		"font_color", SELECTED_LABEL_COLOR if _selected else LABEL_COLOR
	)
	queue_redraw()


## Hit test against the placeholder silhouette, in this node's local space.
func contains_point(local_point: Vector2) -> bool:
	if Geometry2D.is_point_in_polygon(local_point, _body_silhouette):
		return true
	return _has_topper() and Geometry2D.is_point_in_polygon(local_point, _topper_silhouette)


func _draw() -> void:
	if definition == null:
		return

	var pad: PackedVector2Array = _face(
		Vector2(-PAD_MARGIN, -PAD_MARGIN),
		body_tiles + Vector2(PAD_MARGIN * 2.0, PAD_MARGIN * 2.0),
		0.0
	)
	draw_colored_polygon(pad, SELECTED_PAD_COLOR if _selected else PAD_COLOR)

	_draw_box(Vector2.ZERO, body_tiles, 0.0, body_height)
	if _has_topper():
		_draw_box(topper_offset_tiles, topper_tiles, body_height, topper_height)

	if _selected:
		var ring: PackedVector2Array = pad.duplicate()
		ring.append(pad[0])
		draw_polyline(ring, RING_COLOR, 3.0)


func _draw_box(
	offset_tiles: Vector2, size_tiles: Vector2, base_elevation: float, height: float
) -> void:
	var base: PackedVector2Array = _face(offset_tiles, size_tiles, base_elevation)
	var top: PackedVector2Array = _face(offset_tiles, size_tiles, base_elevation + height)

	draw_colored_polygon(
		PackedVector2Array([base[3], base[2], top[2], top[3]]),
		SELECTED_LEFT_COLOR if _selected else BODY_LEFT_COLOR
	)
	draw_colored_polygon(
		PackedVector2Array([base[2], base[1], top[1], top[2]]),
		SELECTED_RIGHT_COLOR if _selected else BODY_RIGHT_COLOR
	)
	draw_colored_polygon(top, SELECTED_TOP_COLOR if _selected else BODY_TOP_COLOR)


## Corners of one horizontal face, ordered north, east, south, west.
func _face(offset_tiles: Vector2, size_tiles: Vector2, elevation: float) -> PackedVector2Array:
	var lift: Vector2 = Vector2(0.0, -elevation)
	return PackedVector2Array([
		Iso.to_screen(offset_tiles) + lift,
		Iso.to_screen(offset_tiles + Vector2(size_tiles.x, 0.0)) + lift,
		Iso.to_screen(offset_tiles + size_tiles) + lift,
		Iso.to_screen(offset_tiles + Vector2(0.0, size_tiles.y)) + lift,
	])


## Outline of a whole box, used for hit testing rather than drawing.
func _silhouette(
	offset_tiles: Vector2, size_tiles: Vector2, base_elevation: float, height: float
) -> PackedVector2Array:
	var base: PackedVector2Array = _face(offset_tiles, size_tiles, base_elevation)
	var top: PackedVector2Array = _face(offset_tiles, size_tiles, base_elevation + height)
	return PackedVector2Array([top[0], top[1], base[1], base[2], base[3], top[3]])


func _has_topper() -> bool:
	return topper_height > 0.0 and topper_tiles.x > 0.0 and topper_tiles.y > 0.0


func _place_name_label() -> void:
	_name_label.text = definition.display_name
	_name_label.add_theme_color_override("font_color", LABEL_COLOR)
	_name_label.reset_size()
	var south_corner: Vector2 = Iso.to_screen(body_tiles)
	_name_label.position = south_corner + Vector2(-_name_label.size.x * 0.5, LABEL_GAP)
