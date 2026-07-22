class_name MachineDefinition
extends Resource

## One dust-producing machine on a customer's shop floor.
##
## `collection_demand` is an abstract game unit used to compare machines, and
## later to compare them against collector capacity. It is a gameplay value,
## not a real-world airflow specification.

@export var machine_id: StringName = &""
@export var display_name: String = ""
@export var collection_demand: int = 0
@export_multiline var description: String = ""
