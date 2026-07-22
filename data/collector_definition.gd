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
