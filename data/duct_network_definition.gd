class_name DuctNetworkDefinition
extends Resource

## The fixed shared ductwork for one shop: the junctions where branches merge
## and the mains that carry the combined airflow to the collector.
##
## Branch geometry is per machine and route and lives in
## `DuctBranchDefinition`. Everything here is common to every proposal.

@export var junctions: Array[DuctJunctionDefinition] = []
## Mains keyed by the junction they leave, so a junction's outlet run is found
## without hard-coding a diameter or an identifier in drawing code.
@export var main_runs: Array[DuctRunDefinition] = []
## Junction id whose outlet run terminates at the collector.
@export var terminal_junction_id: StringName = &""
## Where the collector stands: Vector3(tile_x, tile_y, elevation_px) of its inlet.
@export var collector_inlet: Vector3 = Vector3.ZERO
## Centre of the collector pad in tile space.
@export var collector_pad_center: Vector2 = Vector2.ZERO
@export var collector_pad_size: Vector2 = Vector2(2.0, 2.0)


func junction(junction_id: StringName) -> DuctJunctionDefinition:
	for candidate: DuctJunctionDefinition in junctions:
		if candidate.junction_id == junction_id:
			return candidate
	return null


func main_run(run_id: StringName) -> DuctRunDefinition:
	for run: DuctRunDefinition in main_runs:
		if run.run_id == run_id:
			return run
	return null
