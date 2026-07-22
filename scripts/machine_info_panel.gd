class_name MachineInfoPanel
extends PanelContainer

## Shows the machine the player currently has selected. The panel renders what
## it is given; it never decides what is selected.

const EMPTY_NAME: String = "Select a machine"
const EMPTY_DEMAND: String = "—"
const EMPTY_DESCRIPTION: String = "Click a machine on the shop floor to read what it needs."

@onready var _name_label: Label = $Content/MachineName
@onready var _demand_label: Label = $Content/Demand/DemandValue
@onready var _description_label: Label = $Content/Description


func show_machine(definition: MachineDefinition) -> void:
	_name_label.text = definition.display_name
	_demand_label.text = "%d game units" % definition.collection_demand
	_description_label.text = definition.description


func show_empty() -> void:
	_name_label.text = EMPTY_NAME
	_demand_label.text = EMPTY_DEMAND
	_description_label.text = EMPTY_DESCRIPTION
