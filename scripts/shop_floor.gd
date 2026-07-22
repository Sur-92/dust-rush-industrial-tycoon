class_name ShopFloor
extends Node2D

## Draws the fixed-isometric floor plate the cabinet shop stands on.

@export var tile_columns: int = 10
@export var tile_rows: int = 8
@export var fill_color: Color = Color(0.098, 0.125, 0.161)
@export var grid_color: Color = Color(0.157, 0.196, 0.251)
@export var border_color: Color = Color(0.239, 0.302, 0.373)


func _draw() -> void:
	var columns: float = float(tile_columns)
	var rows: float = float(tile_rows)
	var outline: PackedVector2Array = PackedVector2Array([
		Iso.to_screen(Vector2.ZERO),
		Iso.to_screen(Vector2(columns, 0.0)),
		Iso.to_screen(Vector2(columns, rows)),
		Iso.to_screen(Vector2(0.0, rows)),
	])
	draw_colored_polygon(outline, fill_color)

	for column: int in range(1, tile_columns):
		draw_line(
			Iso.to_screen(Vector2(float(column), 0.0)),
			Iso.to_screen(Vector2(float(column), rows)),
			grid_color,
			1.0
		)
	for row: int in range(1, tile_rows):
		draw_line(
			Iso.to_screen(Vector2(0.0, float(row))),
			Iso.to_screen(Vector2(columns, float(row))),
			grid_color,
			1.0
		)

	var closed_outline: PackedVector2Array = outline.duplicate()
	closed_outline.append(outline[0])
	draw_polyline(closed_outline, border_color, 2.0)
