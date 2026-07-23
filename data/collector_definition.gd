class_name CollectorDefinition
extends Resource

## One dust-collector approach the player can buy for a job.
##
## `capacity` is an abstract game unit compared against machine demand and
## route restriction. These are gameplay abstractions, not real-world
## equipment specifications.

@export var collector_id: StringName = &""
@export var display_name: String = ""
@export var capacity: int = 0
@export var equipment_cost: int = 0
@export var install_seconds: int = 0
@export_multiline var tradeoff: String = ""

@export_group("Silhouette")
## Drawn size of the collector barrel, so the choice is visible in the factory.
@export var body_radius_px: float = 30.0
@export var body_height_px: float = 68.0
@export var hopper_height_px: float = 36.0
@export var leg_height_px: float = 14.0
## Extra filter housing on top, giving the largest option a distinct outline.
@export var has_filter_module: bool = false


## Total drawn height, used to keep the collector clear of the HUD.
func silhouette_height_px() -> float:
	return leg_height_px + hopper_height_px + body_height_px + (28.0 if has_filter_module else 10.0)
