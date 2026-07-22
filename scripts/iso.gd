class_name Iso
extends RefCounted

## Fixed 2:1 isometric projection shared by the shop floor and the machine views.
##
## Tile space accepts fractional tiles so placeholder machines can sit between
## grid lines. Screen space is Godot 2D pixels measured from the tile origin,
## so the caller positions the result with a normal node transform.

const TILE_HALF_WIDTH: float = 48.0
const TILE_HALF_HEIGHT: float = 24.0


static func to_screen(tile: Vector2) -> Vector2:
	return Vector2(
		(tile.x - tile.y) * TILE_HALF_WIDTH,
		(tile.x + tile.y) * TILE_HALF_HEIGHT
	)
