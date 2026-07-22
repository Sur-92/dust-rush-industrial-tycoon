class_name SystemProposal
extends RefCounted

## Gameplay state and arithmetic for one shop's dust-collection proposal.
##
## Holds no scene, node, or UI reference, so the rules below can be exercised
## headlessly. Every value is derived from the typed definitions the proposal
## is given; nothing branches on a collector or route identifier.

enum Fit {
	UNKNOWN, ## No collector chosen yet, so capacity is not known.
	SHORT,
	TIGHT,
	COMFORTABLE,
}

## Lowest capacity margin that still counts as comfortable.
const COMFORTABLE_MARGIN: int = 2

var machines: Array[MachineDefinition] = []
var collector: CollectorDefinition = null

var _routes: Dictionary[StringName, RouteDefinition] = {}


func set_machines(value: Array[MachineDefinition]) -> void:
	machines = value
	_routes.clear()


func clear() -> void:
	collector = null
	_routes.clear()


func set_route(machine_id: StringName, route: RouteDefinition) -> void:
	_routes[machine_id] = route


func route_for(machine_id: StringName) -> RouteDefinition:
	return _routes.get(machine_id)


func total_demand() -> int:
	var total: int = 0
	for machine: MachineDefinition in machines:
		total += machine.collection_demand
	return total


func collector_capacity() -> int:
	return collector.capacity if collector != null else 0


func total_restriction() -> int:
	var total: int = 0
	for route: RouteDefinition in _chosen_routes():
		total += route.restriction
	return total


func usable_capacity() -> int:
	return collector_capacity() - total_restriction()


func capacity_margin() -> int:
	return usable_capacity() - total_demand()


func expansion_room() -> int:
	return maxi(capacity_margin(), 0)


func total_cost() -> int:
	var total: int = collector.equipment_cost if collector != null else 0
	for route: RouteDefinition in _chosen_routes():
		total += route.cost
	return total


func total_install_seconds() -> int:
	var total: int = collector.install_seconds if collector != null else 0
	for route: RouteDefinition in _chosen_routes():
		total += route.install_seconds
	return total


func has_collector() -> bool:
	return collector != null


func machines_missing_routes() -> Array[MachineDefinition]:
	var missing: Array[MachineDefinition] = []
	for machine: MachineDefinition in machines:
		if route_for(machine.machine_id) == null:
			missing.append(machine)
	return missing


func is_complete() -> bool:
	return has_collector() and machines_missing_routes().is_empty()


func fit() -> Fit:
	if not has_collector():
		return Fit.UNKNOWN

	var margin: int = capacity_margin()
	if margin < 0:
		return Fit.SHORT
	if margin < COMFORTABLE_MARGIN:
		return Fit.TIGHT
	return Fit.COMFORTABLE


## Player-facing summary of what the proposal still needs, or that it is ready.
func completion_text() -> String:
	if is_complete():
		return "Proposal ready"

	var missing: PackedStringArray = PackedStringArray()
	if not has_collector():
		missing.append("a collector")

	var unrouted: Array[MachineDefinition] = machines_missing_routes()
	if unrouted.size() == 1:
		missing.append("a route for the %s" % unrouted[0].display_name)
	elif unrouted.size() > 1:
		missing.append("routes for %d machines" % unrouted.size())

	return "Still needs " + " and ".join(missing) + "."


static func fit_label(value: Fit) -> String:
	match value:
		Fit.SHORT:
			return "Short"
		Fit.TIGHT:
			return "Tight"
		Fit.COMFORTABLE:
			return "Comfortable"
	return "—"


func _chosen_routes() -> Array[RouteDefinition]:
	var chosen: Array[RouteDefinition] = []
	for machine: MachineDefinition in machines:
		var route: RouteDefinition = route_for(machine.machine_id)
		if route != null:
			chosen.append(route)
	return chosen
