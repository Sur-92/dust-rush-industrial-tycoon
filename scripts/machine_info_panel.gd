class_name MachineInfoPanel
extends PanelContainer

## Shows the selected machine and offers its route choices. The panel renders
## what it is given and forwards route intent; it never decides what is
## selected or which route is saved.

signal route_chosen(route_id: StringName)

const EMPTY_NAME: String = "Select a machine"
const EMPTY_AIRFLOW: String = "—"
const EMPTY_PICKUP: String = "Select a machine to see its pickups."
const EMPTY_DESCRIPTION: String = "Click a machine on the shop floor to read what it needs."
const EMPTY_ROUTE_DETAIL: String = "Select a machine to choose how its duct is routed."
const UNROUTED_DETAIL: String = "Pick a route approach for this machine."

@onready var _name_label: Label = $Content/MachineName
@onready var _airflow_label: Label = $Content/Airflow/AirflowValue
@onready var _pickup_label: Label = $Content/Airflow/PickupValue
@onready var _description_label: Label = $Content/Description
@onready var _route_detail_label: Label = $Content/RouteDetail
@onready var _route_buttons_root: HBoxContainer = $Content/RouteButtons

var _route_buttons: Array[RouteButton] = []


func _ready() -> void:
	for child: Node in _route_buttons_root.get_children():
		var button := child as RouteButton
		if button == null:
			continue
		_route_buttons.append(button)
		button.chosen.connect(_on_route_chosen)


## Route approaches offered by this panel, so the controller can resolve the
## ids it receives without a second copy of the list.
func route_definitions() -> Array[RouteDefinition]:
	var definitions: Array[RouteDefinition] = []
	for button: RouteButton in _route_buttons:
		if button.definition != null:
			definitions.append(button.definition)
	return definitions


func show_machine(definition: MachineDefinition, chosen_route: RouteDefinition) -> void:
	_name_label.text = definition.display_name
	_airflow_label.text = "%s CFM" % GameFormat.integer(definition.airflow_cfm)
	_pickup_label.text = definition.pickup_summary()
	_description_label.text = definition.description

	for button: RouteButton in _route_buttons:
		button.disabled = false
		button.set_chosen(
			chosen_route != null and button.definition.route_id == chosen_route.route_id
		)

	_route_detail_label.text = (
		chosen_route.tradeoff if chosen_route != null else UNROUTED_DETAIL
	)


func show_empty() -> void:
	_name_label.text = EMPTY_NAME
	_airflow_label.text = EMPTY_AIRFLOW
	_pickup_label.text = EMPTY_PICKUP
	_description_label.text = EMPTY_DESCRIPTION
	_route_detail_label.text = EMPTY_ROUTE_DETAIL

	for button: RouteButton in _route_buttons:
		button.set_chosen(false)
		button.disabled = true


func _on_route_chosen(route_id: StringName) -> void:
	route_chosen.emit(route_id)
