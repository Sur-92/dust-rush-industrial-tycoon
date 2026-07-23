extends SceneTree

## Deterministic checks for the duct engineering layer: the formulas in
## `scripts/duct_math.gd`, the airflow resolution in
## `scripts/duct_calculation.gd`, and the geometry data under `data/ducts/`.
##
## Plain Godot, no third-party framework. Run with:
##   godot --headless --path . -s res://tests/test_duct_engineering.gd

const MACHINE_PATHS: Array[String] = [
	"res://data/machines/table_saw.tres",
	"res://data/machines/planer.tres",
	"res://data/machines/wide_belt_sander.tres",
]
const ROUTE_IDS: Array[StringName] = [&"direct", &"sweeping"]
const TOLERANCE: float = 0.0001

var failures: PackedStringArray = PackedStringArray()
var checks: int = 0

var machines: Array[MachineDefinition] = []
var network: DuctNetworkDefinition = null


func _initialize() -> void:
	for path: String in MACHINE_PATHS:
		machines.append(load(path) as MachineDefinition)
	network = load("res://data/ducts/cabinet_shop_network.tres")

	_check_scenario_inputs()
	_check_formulas()
	_check_pickup_and_junction_sums()
	_check_main_states()
	_check_precision_versus_display()
	_check_topology_continuity()
	_check_route_geometry_differs()
	_check_partial_and_cleared_networks()

	_report()


## The engineering layer is only meaningful if the approved scenario inputs and
## their provenance are still what `docs/ENGINEERING_MODEL.md` records.
func _check_scenario_inputs() -> void:
	var expected: Array = [
		[&"table_saw", 400, 1, 4.0, 4.0],
		[&"planer", 600, 1, 5.0, 5.0],
		[&"wide_belt_sander", 800, 2, 4.0, 6.0],
	]
	for index: int in range(expected.size()):
		var machine: MachineDefinition = machines[index]
		_equal(machine.machine_id, expected[index][0], "machine id %d" % index)
		_equal(machine.airflow_cfm, expected[index][1], "%s airflow" % machine.machine_id)
		_equal(machine.pickup_count, expected[index][2], "%s pickup count" % machine.machine_id)
		_close(
			machine.pickup_diameter_inches, expected[index][3],
			"%s pickup diameter" % machine.machine_id
		)
		_close(
			machine.branch_diameter_inches, expected[index][4],
			"%s branch diameter" % machine.machine_id
		)
		_true(machine.airflow_source != null, "%s has a source" % machine.machine_id)
		if machine.airflow_source != null:
			_equal(
				machine.airflow_source.classification,
				EngineeringSource.Classification.SCENARIO_INPUT,
				"%s source classification" % machine.machine_id
			)
			_true(
				machine.airflow_source.url.begins_with("https://"),
				"%s source url" % machine.machine_id
			)
			_true(
				machine.airflow_source.accessed != "",
				"%s source access date" % machine.machine_id
			)

	# The sander's airflow must split evenly across its two pickups.
	_close(machines[2].airflow_per_pickup_cfm(), 400.0, "sander airflow per pickup")
	_close(machines[0].airflow_per_pickup_cfm(), 400.0, "saw airflow per pickup")


## Inch-to-foot conversion, round area, velocity, and velocity pressure.
func _check_formulas() -> void:
	_close(DuctMath.diameter_feet(12.0), 1.0, "12 inches is one foot")
	_close(DuctMath.diameter_feet(6.0), 0.5, "6 inches is half a foot")

	# A = pi * D^2 / 4 with D in feet. A one-foot duct is pi/4 square feet.
	_close(DuctMath.round_area_square_feet(12.0), PI / 4.0, "one-foot duct area")
	_close(DuctMath.round_area_square_feet(6.0), PI * 0.25 / 4.0, "6-inch duct area")

	# Inches must never be treated as feet: a 7-inch duct is not 7 feet across.
	_close(DuctMath.round_area_square_feet(7.0), PI * pow(7.0 / 12.0, 2.0) / 4.0, "7-inch area")
	_true(
		DuctMath.round_area_square_feet(7.0) < 0.3,
		"7-inch area stays in square feet, not implied feet"
	)

	# The doc worked example: a 7-inch main at 1,000 CFM is about 3,742 FPM.
	var main_area: float = DuctMath.round_area_square_feet(7.0)
	_true(absf(main_area - 0.267) < 0.001, "7-inch area rounds to 0.267 sq ft")
	var main_velocity: float = DuctMath.velocity_fpm(1000.0, 7.0)
	_true(absf(main_velocity - 3742.0) < 1.5, "7-inch main velocity near 3,742 FPM")

	# V = Q / A, and Q = V * A must invert it exactly.
	_close(DuctMath.airflow_cfm(main_velocity, 7.0), 1000.0, "airflow inverts velocity")

	# VP = (V / 4005)^2. At exactly 4005 FPM velocity pressure is 1.0 in w.g.
	_close(DuctMath.velocity_pressure_inwg(4005.0), 1.0, "velocity pressure at 4005 FPM")
	_close(DuctMath.velocity_pressure_inwg(0.0), 0.0, "velocity pressure at rest")
	_close(
		DuctMath.velocity_pressure_inwg(2002.5), 0.25,
		"velocity pressure scales with the square"
	)

	# Same airflow through a wider duct must be slower.
	_true(
		DuctMath.velocity_fpm(800.0, 9.0) < DuctMath.velocity_fpm(800.0, 6.0),
		"wider duct lowers velocity at equal airflow"
	)


func _check_pickup_and_junction_sums() -> void:
	var calculation: DuctCalculation = _calculation([&"table_saw", &"planer", &"wide_belt_sander"])

	_close(calculation.pickup_airflow_cfm(&"table_saw"), 400.0, "saw pickup CFM")
	_close(calculation.pickup_airflow_cfm(&"planer"), 600.0, "planer pickup CFM")
	_close(calculation.pickup_airflow_cfm(&"wide_belt_sander"), 400.0, "sander pickup CFM each")

	# The sander's two 400 CFM pickups merge into one 800 CFM 6-inch branch.
	_close(calculation.junction_airflow(&"sander_merge"), 800.0, "sander merge CFM")
	var merge: DuctCalculation.Transition = _transition(calculation, &"sander_merge")
	_equal(merge.inlet_airflows.size(), 2, "sander merge shows two inlets")
	_close(merge.inlet_airflows[0], 400.0, "sander merge inlet 1")
	_close(merge.inlet_airflows[1], 400.0, "sander merge inlet 2")
	_close(merge.outlet.diameter_inches, 6.0, "sander merge outlet diameter")
	_equal(merge.airflow_sum_text(), "400 CFM + 400 CFM = 800 CFM", "sander merge sum text")

	# Table saw plus planer make the 1,000 CFM seven-inch main.
	var main_7: DuctCalculation.Transition = _transition(calculation, &"main_7")
	_close(main_7.inlet_diameters[0], 4.0, "main 7 inlet diameter 1")
	_close(main_7.inlet_diameters[1], 5.0, "main 7 inlet diameter 2")
	_equal(main_7.airflow_sum_text(), "400 CFM + 600 CFM = 1,000 CFM", "main 7 sum text")

	# That main plus the sander branch make the 1,800 CFM nine-inch main.
	var main_9: DuctCalculation.Transition = _transition(calculation, &"main_9")
	_close(main_9.inlet_diameters[0], 7.0, "main 9 inlet diameter 1")
	_close(main_9.inlet_diameters[1], 6.0, "main 9 inlet diameter 2")
	_equal(main_9.airflow_sum_text(), "1,000 CFM + 800 CFM = 1,800 CFM", "main 9 sum text")


func _check_main_states() -> void:
	var calculation: DuctCalculation = _calculation([&"table_saw", &"planer", &"wide_belt_sander"])

	_close(calculation.junction_airflow(&"main_7"), 1000.0, "seven-inch main carries 1,000 CFM")
	_close(calculation.junction_airflow(&"main_9"), 1800.0, "nine-inch main carries 1,800 CFM")
	_close(calculation.total_airflow_cfm(), 1800.0, "total network airflow")

	var main_7: DuctCalculation.Transition = _transition(calculation, &"main_7")
	_close(main_7.outlet.diameter_inches, 7.0, "main 7 diameter")
	_close(main_7.outlet.area_square_feet, DuctMath.round_area_square_feet(7.0), "main 7 area")
	_close(main_7.outlet.velocity_fpm, 1000.0 / main_7.outlet.area_square_feet, "main 7 velocity")
	_close(
		main_7.outlet.velocity_pressure_inwg,
		DuctMath.velocity_pressure_inwg(main_7.outlet.velocity_fpm),
		"main 7 velocity pressure"
	)

	var main_9: DuctCalculation.Transition = _transition(calculation, &"main_9")
	_close(main_9.outlet.diameter_inches, 9.0, "main 9 diameter")
	_close(main_9.outlet.airflow_cfm, 1800.0, "main 9 airflow")

	# Stepping 7 to 9 inches at the junction keeps velocity from climbing even
	# though airflow rose by 800 CFM.
	_true(
		main_9.outlet.velocity_fpm < main_7.outlet.velocity_fpm * 1.2,
		"nine-inch step keeps velocity in hand"
	)


## Calculations keep full precision; only the display helpers round.
func _check_precision_versus_display() -> void:
	var velocity: float = DuctMath.velocity_fpm(1000.0, 7.0)
	_true(absf(velocity - roundf(velocity)) > 0.0, "velocity keeps a fractional part")
	_equal(GameFormat.integer(velocity), "3,742", "velocity display rounds to whole FPM")
	_true(velocity != float(int(velocity)), "stored velocity is not truncated")

	var area: float = DuctMath.round_area_square_feet(7.0)
	_equal(GameFormat.decimal(area, 3), "0.267", "area displays to three places")
	_true(absf(area - 0.267) > 0.0, "stored area is more precise than its display")

	var pressure: float = DuctMath.velocity_pressure_inwg(velocity)
	_equal(GameFormat.decimal(pressure, 2), "0.87", "velocity pressure displays to two places")
	_true(absf(pressure - 0.87) > 0.0, "stored velocity pressure keeps precision")

	# Rounding for display must never feed back into a calculation.
	var from_rounded: float = DuctMath.velocity_pressure_inwg(roundf(velocity))
	_true(absf(from_rounded - pressure) > 0.0, "display rounding is not reused as input")


## Every machine and route combination must form one continuous path from the
## machine's pickups to the collector.
func _check_topology_continuity() -> void:
	var junction_for: Dictionary[StringName, StringName] = {
		&"table_saw": &"main_7",
		&"planer": &"main_7",
		&"wide_belt_sander": &"main_9",
	}

	for machine: MachineDefinition in machines:
		for route_id: StringName in ROUTE_IDS:
			var label: String = "%s/%s" % [machine.machine_id, route_id]
			var branch: DuctBranchDefinition = _branch(machine.machine_id, route_id)
			_true(branch != null, "%s branch exists" % label)
			if branch == null:
				continue

			_equal(branch.pickup_runs.size(), machine.pickup_count, "%s pickup run count" % label)
			_true(branch.branch_run != null, "%s has a branch run" % label)

			for run: DuctRunDefinition in branch.pickup_runs:
				_close(
					run.diameter_inches, machine.pickup_diameter_inches,
					"%s pickup diameter" % label
				)
				_true(run.point_count() >= 2, "%s pickup run has a path" % label)

			_close(
				branch.branch_run.diameter_inches, machine.branch_diameter_inches,
				"%s branch diameter" % label
			)

			# Pickups must all arrive where the branch run starts.
			var branch_start: Vector3 = branch.branch_run.waypoints[0]
			for run: DuctRunDefinition in branch.pickup_runs:
				var pickup_end: Vector3 = run.waypoints[run.point_count() - 1]
				_true(
					pickup_end.distance_to(branch_start) < 0.001,
					"%s pickup meets the branch start" % label
				)

			# The branch must end exactly on the junction it feeds.
			var junction: DuctJunctionDefinition = network.junction(junction_for[machine.machine_id])
			var branch_end: Vector3 = branch.branch_run.waypoints[branch.branch_run.point_count() - 1]
			_true(
				branch_end.distance_to(junction.position) < 0.001,
				"%s branch meets %s" % [label, junction.junction_id]
			)

			# No zero-length hops, which would draw as invisible kinks.
			for index: int in range(1, branch.branch_run.point_count()):
				var step: float = branch.branch_run.waypoints[index].distance_to(
					branch.branch_run.waypoints[index - 1]
				)
				_true(step > 0.001, "%s branch step %d has length" % [label, index])

	# The mains must chain the junctions together and reach the collector.
	var main_7_run: DuctRunDefinition = network.main_run(&"main_7_run")
	var main_9_run: DuctRunDefinition = network.main_run(&"main_9_run")
	_true(main_7_run != null and main_9_run != null, "both mains exist")
	_close(main_7_run.diameter_inches, 7.0, "main 7 run diameter")
	_close(main_9_run.diameter_inches, 9.0, "main 9 run diameter")
	_true(
		main_7_run.waypoints[0].distance_to(network.junction(&"main_7").position) < 0.001,
		"seven-inch main leaves its junction"
	)
	_true(
		main_7_run.waypoints[main_7_run.point_count() - 1].distance_to(
			network.junction(&"main_9").position
		) < 0.001,
		"seven-inch main reaches the nine-inch junction"
	)
	_true(
		main_9_run.waypoints[0].distance_to(network.junction(&"main_9").position) < 0.001,
		"nine-inch main leaves its junction"
	)
	_true(
		main_9_run.waypoints[main_9_run.point_count() - 1].distance_to(
			network.collector_inlet
		) < 0.001,
		"nine-inch main terminates at the collector inlet"
	)


## Direct and Sweeping must be tellable apart from the factory, so the geometry
## itself has to differ, not only the button text.
func _check_route_geometry_differs() -> void:
	for machine: MachineDefinition in machines:
		var direct: DuctBranchDefinition = _branch(machine.machine_id, &"direct")
		var sweeping: DuctBranchDefinition = _branch(machine.machine_id, &"sweeping")

		_true(
			sweeping.plan_length_tiles() > direct.plan_length_tiles() + 0.5,
			"%s sweeping is visibly longer (%.2f vs %.2f)" % [
				machine.machine_id, sweeping.plan_length_tiles(), direct.plan_length_tiles()
			]
		)
		_true(
			sweeping.corner_count() > direct.corner_count(),
			"%s sweeping bends more often" % machine.machine_id
		)
		_close(direct.branch_run.bend_radius, 0.0, "%s direct is a sharp turn" % machine.machine_id)
		_true(
			sweeping.branch_run.bend_radius > 0.0,
			"%s sweeping uses broad bends" % machine.machine_id
		)


## An incomplete proposal must report only the airflow actually connected, and
## clearing it must return the network to zero.
func _check_partial_and_cleared_networks() -> void:
	var empty: DuctCalculation = _calculation([])
	_close(empty.total_airflow_cfm(), 0.0, "empty network carries nothing")
	_close(empty.junction_airflow(&"main_7"), 0.0, "empty seven-inch main")
	_close(empty.junction_airflow(&"sander_merge"), 0.0, "empty sander merge")
	_equal(empty.machine_segments().size(), 0, "empty network has no segments")

	var saw_only: DuctCalculation = _calculation([&"table_saw"])
	_close(saw_only.total_airflow_cfm(), 400.0, "saw alone carries 400 CFM")
	_close(saw_only.junction_airflow(&"sander_merge"), 0.0, "unrouted sander adds nothing")

	var without_sander: DuctCalculation = _calculation([&"table_saw", &"planer"])
	_close(without_sander.junction_airflow(&"main_7"), 1000.0, "saw and planer make 1,000 CFM")
	_close(without_sander.total_airflow_cfm(), 1000.0, "main carries only what is routed")

	var sander_only: DuctCalculation = _calculation([&"wide_belt_sander"])
	_close(sander_only.total_airflow_cfm(), 800.0, "sander alone carries 800 CFM")
	_close(sander_only.junction_airflow(&"main_7"), 0.0, "unrouted saw and planer add nothing")

	# The saw contributes one pickup segment; the sander contributes two pickups
	# plus its merged branch.
	_equal(saw_only.machine_segments().size(), 1, "saw contributes one segment")
	_equal(sander_only.machine_segments().size(), 2, "sander contributes pickup and branch")

	# Re-clearing returns to the empty state, which is what Restart relies on.
	var reused: DuctCalculation = _calculation([&"table_saw", &"planer", &"wide_belt_sander"])
	_close(reused.total_airflow_cfm(), 1800.0, "full network before clearing")
	reused.set_routed_machines([])
	_close(reused.total_airflow_cfm(), 0.0, "cleared network carries nothing")
	_equal(reused.machine_segments().size(), 0, "cleared network has no segments")


func _calculation(routed: Array[StringName]) -> DuctCalculation:
	var calculation: DuctCalculation = DuctCalculation.new()
	calculation.configure(network, machines)
	calculation.set_routed_machines(routed)
	return calculation


func _transition(
	calculation: DuctCalculation, junction_id: StringName
) -> DuctCalculation.Transition:
	for transition: DuctCalculation.Transition in calculation.transitions():
		if transition.junction_id == junction_id:
			return transition
	failures.append("missing transition %s" % junction_id)
	return null


func _branch(machine_id: StringName, route_id: StringName) -> DuctBranchDefinition:
	return load("res://data/ducts/%s_%s.tres" % [machine_id, route_id])


func _close(actual: float, expected: float, label: String) -> void:
	checks += 1
	if absf(actual - expected) > TOLERANCE:
		failures.append("%s: expected %f, got %f" % [label, expected, actual])


func _equal(actual: Variant, expected: Variant, label: String) -> void:
	checks += 1
	if actual != expected:
		failures.append("%s: expected %s, got %s" % [label, expected, actual])


func _true(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures.append(label)


func _report() -> void:
	if failures.is_empty():
		print("DUCT ENGINEERING TESTS PASSED (%d checks)" % checks)
		quit(0)
		return

	print("DUCT ENGINEERING TESTS FAILED (%d of %d checks)" % [failures.size(), checks])
	for failure: String in failures:
		print("  - " + failure)
	quit(1)
