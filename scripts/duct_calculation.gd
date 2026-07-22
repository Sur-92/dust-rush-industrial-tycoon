class_name DuctCalculation
extends RefCounted

## Resolves one proposal into the airflow the shop's ductwork actually carries.
##
## Holds no scene reference and reads no node, so it can be exercised headlessly.
## Airflow is summed by walking the junction inlet ids in the network data; the
## arithmetic never branches on a machine, route, or collector identifier.

## One constant-diameter length of duct with its resolved airflow.
class Segment extends RefCounted:
	var label: String = ""
	var diameter_inches: float = 0.0
	var airflow_cfm: float = 0.0
	var area_square_feet: float = 0.0
	var velocity_fpm: float = 0.0
	var velocity_pressure_inwg: float = 0.0

	func _init(segment_label: String, diameter: float, airflow: float) -> void:
		label = segment_label
		diameter_inches = diameter
		airflow_cfm = airflow
		area_square_feet = DuctMath.round_area_square_feet(diameter)
		velocity_fpm = DuctMath.velocity_fpm(airflow, diameter)
		velocity_pressure_inwg = DuctMath.velocity_pressure_inwg(velocity_fpm)


## One place where airflow is added and the duct steps up.
class Transition extends RefCounted:
	var junction_id: StringName = &""
	var display_name: String = ""
	var explanation: String = ""
	var inlet_labels: PackedStringArray = PackedStringArray()
	var inlet_airflows: PackedFloat64Array = PackedFloat64Array()
	var inlet_diameters: PackedFloat64Array = PackedFloat64Array()
	var outlet: Segment = null

	func airflow_sum_text() -> String:
		var parts: PackedStringArray = PackedStringArray()
		for airflow: float in inlet_airflows:
			parts.append("%s CFM" % GameFormat.integer(airflow))
		return "%s = %s CFM" % [" + ".join(parts), GameFormat.integer(outlet.airflow_cfm)]


var network: DuctNetworkDefinition = null

var _machines: Array[MachineDefinition] = []
var _routed_ids: Array[StringName] = []


func configure(network_definition: DuctNetworkDefinition, machines: Array[MachineDefinition]) -> void:
	network = network_definition
	_machines = machines


## Limits the calculation to machines that currently have a route chosen.
func set_routed_machines(machine_ids: Array[StringName]) -> void:
	_routed_ids = machine_ids


func machine(machine_id: StringName) -> MachineDefinition:
	for candidate: MachineDefinition in _machines:
		if candidate.machine_id == machine_id:
			return candidate
	return null


func is_machine_routed(machine_id: StringName) -> bool:
	return _routed_ids.has(machine_id)


## Airflow arriving from one inlet id, which names either a machine or an
## upstream junction. Unrouted machines contribute nothing.
func airflow_from(inlet_id: StringName) -> float:
	var source: MachineDefinition = machine(inlet_id)
	if source != null:
		return float(source.airflow_cfm) if is_machine_routed(inlet_id) else 0.0

	var upstream: DuctJunctionDefinition = network.junction(inlet_id)
	if upstream == null:
		return 0.0
	return junction_airflow(inlet_id)


func junction_airflow(junction_id: StringName) -> float:
	var definition: DuctJunctionDefinition = network.junction(junction_id)
	if definition == null:
		return 0.0

	if definition.merges_machine_pickups != &"":
		var merged: MachineDefinition = machine(definition.merges_machine_pickups)
		if merged == null or not is_machine_routed(merged.machine_id):
			return 0.0
		return merged.airflow_per_pickup_cfm() * float(merged.pickup_count)

	var total: float = 0.0
	for inlet_id: StringName in definition.inlet_ids:
		total += airflow_from(inlet_id)
	return total


func total_airflow_cfm() -> float:
	return junction_airflow(network.terminal_junction_id)


## Airflow at one machine's pickup, before its own pickups merge.
func pickup_airflow_cfm(machine_id: StringName) -> float:
	var source: MachineDefinition = machine(machine_id)
	if source == null:
		return 0.0
	return source.airflow_per_pickup_cfm()


func pickup_segment(machine_id: StringName) -> Segment:
	var source: MachineDefinition = machine(machine_id)
	if source == null:
		return null
	return Segment.new(
		"%s pickup" % source.display_name,
		source.pickup_diameter_inches,
		source.airflow_per_pickup_cfm()
	)


func branch_segment(machine_id: StringName) -> Segment:
	var source: MachineDefinition = machine(machine_id)
	if source == null:
		return null
	return Segment.new(
		"%s branch" % source.display_name,
		source.branch_diameter_inches,
		float(source.airflow_cfm)
	)


## Every pickup and branch segment for the machines that are currently routed.
func machine_segments() -> Array[Segment]:
	var segments: Array[Segment] = []
	for source: MachineDefinition in _machines:
		if not is_machine_routed(source.machine_id):
			continue
		segments.append(pickup_segment(source.machine_id))
		if not is_equal_approx(source.pickup_diameter_inches, source.branch_diameter_inches):
			segments.append(branch_segment(source.machine_id))
	return segments


## Junctions in data order, resolved against the machines that are routed.
func transitions() -> Array[Transition]:
	var results: Array[Transition] = []

	for definition: DuctJunctionDefinition in network.junctions:
		var transition: Transition = Transition.new()
		transition.junction_id = definition.junction_id
		transition.display_name = definition.display_name
		transition.explanation = definition.explanation

		if definition.merges_machine_pickups != &"":
			var merged: MachineDefinition = machine(definition.merges_machine_pickups)
			var routed: bool = merged != null and is_machine_routed(merged.machine_id)
			for index: int in range(merged.pickup_count if merged != null else 0):
				transition.inlet_labels.append(
					"%s pickup %d" % [merged.display_name, index + 1]
				)
				transition.inlet_airflows.append(
					merged.airflow_per_pickup_cfm() if routed else 0.0
				)
				transition.inlet_diameters.append(merged.pickup_diameter_inches)
		else:
			for inlet_id: StringName in definition.inlet_ids:
				transition.inlet_labels.append(_inlet_label(inlet_id))
				transition.inlet_airflows.append(airflow_from(inlet_id))
				transition.inlet_diameters.append(_inlet_diameter(inlet_id))

		transition.outlet = Segment.new(
			definition.display_name,
			definition.outlet_diameter_inches,
			junction_airflow(definition.junction_id)
		)
		results.append(transition)

	return results


func _inlet_label(inlet_id: StringName) -> String:
	var source: MachineDefinition = machine(inlet_id)
	if source != null:
		return source.display_name

	var upstream: DuctJunctionDefinition = network.junction(inlet_id)
	return upstream.display_name if upstream != null else String(inlet_id)


func _inlet_diameter(inlet_id: StringName) -> float:
	var source: MachineDefinition = machine(inlet_id)
	if source != null:
		return source.branch_diameter_inches

	var upstream: DuctJunctionDefinition = network.junction(inlet_id)
	return upstream.outlet_diameter_inches if upstream != null else 0.0
