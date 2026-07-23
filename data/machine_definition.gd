class_name MachineDefinition
extends Resource

## One dust-producing machine on a customer's shop floor.
##
## Two layers live side by side on purpose. `collection_demand` is the abstract
## gameplay unit used for collector capacity, margin, and fit. The airflow
## fields below are the scenario engineering inputs from
## `docs/ENGINEERING_MODEL.md` and drive the duct network and the receipt.
## Neither layer is derived from the other.

@export var machine_id: StringName = &""
@export var display_name: String = ""
@export var collection_demand: int = 0
@export_multiline var description: String = ""

@export_group("Airflow")
## Design airflow for this fictional machine, in cubic feet per minute.
@export var airflow_cfm: int = 0
@export var pickup_count: int = 1
@export var pickup_diameter_inches: float = 4.0
## Diameter this machine's pickups merge into before reaching a shop junction.
@export var branch_diameter_inches: float = 4.0
@export var airflow_source: EngineeringSource


## Airflow carried by each individual pickup, split evenly across them.
func airflow_per_pickup_cfm() -> float:
	if pickup_count <= 0:
		return 0.0
	return float(airflow_cfm) / float(pickup_count)


func pickup_summary() -> String:
	var plural: String = "pickups" if pickup_count > 1 else "pickup"
	return "%d × %s-inch %s" % [
		pickup_count, GameFormat.trim_number(pickup_diameter_inches), plural
	]
