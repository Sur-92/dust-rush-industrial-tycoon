class_name DuctBranchDefinition
extends Resource

## The ductwork one machine gets for one route approach: its pickup stubs plus
## the run that carries the merged airflow to a shop junction.

@export var machine_id: StringName = &""
@export var route_id: StringName = &""
## Pickup stubs, one per machine pickup, each at the machine's pickup diameter.
@export var pickup_runs: Array[DuctRunDefinition] = []
## The merged run from this machine to its junction.
@export var branch_run: DuctRunDefinition


func all_runs() -> Array[DuctRunDefinition]:
	var runs: Array[DuctRunDefinition] = []
	runs.append_array(pickup_runs)
	if branch_run != null:
		runs.append(branch_run)
	return runs


## Total plan length, used to show that Sweeping really is the longer route.
func plan_length_tiles() -> float:
	var total: float = 0.0
	for run: DuctRunDefinition in all_runs():
		total += run.plan_length_tiles()
	return total


func corner_count() -> int:
	var total: int = 0
	for run: DuctRunDefinition in all_runs():
		total += run.corner_count()
	return total
