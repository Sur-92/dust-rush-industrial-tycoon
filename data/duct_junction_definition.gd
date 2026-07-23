class_name DuctJunctionDefinition
extends Resource

## One place where airflows merge and the duct steps up in diameter.
##
## `inlet_ids` name machines or upstream junctions. The calculation walks these
## ids to sum airflow, so adding a machine or a junction is a data change.

@export var junction_id: StringName = &""
## Machine ids and/or upstream junction ids feeding this junction.
@export var inlet_ids: Array[StringName] = []
## When set, this junction merges that machine's own pickups instead of whole
## branches, so a two-pickup machine shows 400 + 400 rather than one 800.
@export var merges_machine_pickups: StringName = &""
## Diameter of the duct leaving this junction, in inches.
@export var outlet_diameter_inches: float = 7.0
## Where the fitting sits: Vector3(tile_x, tile_y, elevation_px).
@export var position: Vector3 = Vector3.ZERO
## Player-facing name of the fitting, for example "4 and 5 inch into 7 inch".
@export var display_name: String = ""
@export_multiline var explanation: String = ""
