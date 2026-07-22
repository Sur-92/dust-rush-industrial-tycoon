class_name MachineView
extends Node2D

## One machine standing on the shop floor.
##
## The view owns presentation only: it reports a click as selection intent and
## renders whatever selection and route state the run controller hands back.
##
## Hit testing uses the logical isometric footprint below, never the artwork's
## transparent pixels, so the click target stays generous and predictable.

signal selection_requested(machine_id: StringName)

const PAD_MARGIN: float = 0.18
const LABEL_GAP: float = 10.0

const PAD_COLOR: Color = Color(0.055, 0.071, 0.098, 0.85)
const SELECTED_PAD_COLOR: Color = Color(0.318, 0.224, 0.106, 0.9)
const BODY_TOP_COLOR: Color = Color(0.408, 0.475, 0.573)
const BODY_RIGHT_COLOR: Color = Color(0.271, 0.325, 0.408)
const BODY_LEFT_COLOR: Color = Color(0.192, 0.235, 0.302)
const RING_COLOR: Color = Color(0.957, 0.659, 0.267)
const LABEL_COLOR: Color = Color(0.69, 0.749, 0.82)
const SELECTED_LABEL_COLOR: Color = Color(0.976, 0.788, 0.482)
const ROUTE_MISSING_COLOR: Color = Color(0.957, 0.659, 0.267)
const ROUTE_SET_COLOR: Color = Color(0.588, 0.827, 0.722)
const ROUTE_MISSING_TEXT: String = "Route needed"

@export var definition: MachineDefinition

@export_group("Footprint")
## Top corner of the machine's floor footprint, in tile space.
@export var tile_position: Vector2 = Vector2.ZERO
## Footprint size in tiles. Also sets the width of the logical click target.
@export var body_tiles: Vector2 = Vector2(2.0, 2.0)
## Logical height in pixels. Sets how far the click target reaches above the floor.
@export var body_height: float = 36.0

@export_group("Artwork")
## Approved sprite. When empty the view falls back to placeholder geometry.
@export var texture: Texture2D
@export var texture_scale: float = 1.0
## Source-texture pixel that rests on the footprint's front corner.
@export var texture_anchor: Vector2 = Vector2.ZERO

@onready var _name_label: Label = $NameLabel
@onready var _route_label: Label = $RouteLabel

var _selected: bool = false
var _body_silhouette: PackedVector2Array = PackedVector2Array()


func _ready() -> void:
	if definition == null:
		push_error("MachineView '%s' has no MachineDefinition assigned." % name)
		set_process_unhandled_input(false)
		return

	position = Iso.to_screen(tile_position)
	_body_silhouette = _silhouette(Vector2.ZERO, body_tiles, 0.0, body_height)
	_place_labels()
	set_route(null)
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


## Shows the route the controller has saved for this machine, so the choice
## stays legible after the player selects a different machine.
func set_route(route: RouteDefinition) -> void:
	if route == null:
		_route_label.text = ROUTE_MISSING_TEXT
		_route_label.add_theme_color_override("font_color", ROUTE_MISSING_COLOR)
	else:
		_route_label.text = "%s route" % route.display_name
		_route_label.add_theme_color_override("font_color", ROUTE_SET_COLOR)
	_position_route_label()


## Hit test against the logical footprint, in this node's local space.
func contains_point(local_point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(local_point, _body_silhouette)


func _draw() -> void:
	if definition == null:
		return

	var pad: PackedVector2Array = _face(
		Vector2(-PAD_MARGIN, -PAD_MARGIN),
		body_tiles + Vector2(PAD_MARGIN * 2.0, PAD_MARGIN * 2.0),
		0.0
	)
	draw_colored_polygon(pad, SELECTED_PAD_COLOR if _selected else PAD_COLOR)

	if texture != null:
		draw_texture_rect(texture, _texture_rect(), false)
	else:
		_draw_placeholder_box(Vector2.ZERO, body_tiles, 0.0, body_height)

	if _selected:
		var ring: PackedVector2Array = pad.duplicate()
		ring.append(pad[0])
		draw_polyline(ring, RING_COLOR, 3.0)


## Places the artwork so `texture_anchor` lands on the footprint's front corner.
func _texture_rect() -> Rect2:
	var drawn_size: Vector2 = texture.get_size() * texture_scale
	var front_corner: Vector2 = Iso.to_screen(body_tiles)
	return Rect2(front_corner - texture_anchor * texture_scale, drawn_size)


func _draw_placeholder_box(
	offset_tiles: Vector2, size_tiles: Vector2, base_elevation: float, height: float
) -> void:
	var base: PackedVector2Array = _face(offset_tiles, size_tiles, base_elevation)
	var top: PackedVector2Array = _face(offset_tiles, size_tiles, base_elevation + height)

	draw_colored_polygon(PackedVector2Array([base[3], base[2], top[2], top[3]]), BODY_LEFT_COLOR)
	draw_colored_polygon(PackedVector2Array([base[2], base[1], top[1], top[2]]), BODY_RIGHT_COLOR)
	draw_colored_polygon(top, BODY_TOP_COLOR)


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


func _place_labels() -> void:
	_name_label.text = definition.display_name
	_name_label.add_theme_color_override("font_color", LABEL_COLOR)
	_name_label.reset_size()
	_name_label.position = Iso.to_screen(body_tiles) + Vector2(
		-_name_label.size.x * 0.5, LABEL_GAP
	)


func _position_route_label() -> void:
	_route_label.reset_size()
	_route_label.position = Vector2(
		Iso.to_screen(body_tiles).x - _route_label.size.x * 0.5,
		_name_label.position.y + _name_label.size.y + 1.0
	)
