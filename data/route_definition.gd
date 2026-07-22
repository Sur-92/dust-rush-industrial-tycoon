class_name RouteDefinition
extends Resource

## One duct-routing approach the player can pick for a single machine.
##
## `restriction` is subtracted from collector capacity, so smoother routes
## leave more usable capacity. These are gameplay abstractions, not real-world
## duct calculations.

@export var route_id: StringName = &""
@export var display_name: String = ""
@export var restriction: int = 0
@export var cost: int = 0
@export var install_seconds: int = 0
@export_multiline var tradeoff: String = ""
