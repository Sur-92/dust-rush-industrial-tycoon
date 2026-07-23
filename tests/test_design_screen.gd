extends SceneTree

## Deterministic checks for the design screen's behaviour: what ductwork and
## collector appear for a given proposal, when the engineering receipt becomes
## available, and what Restart clears.
##
## Drives the real scene through the run controller rather than through mouse
## input, so it runs headlessly. Plain Godot, no third-party framework:
##   godot --headless --path . -s res://tests/test_design_screen.gd

const MACHINE_IDS: Array[StringName] = [&"table_saw", &"planer", &"wide_belt_sander"]
const ROUTE_IDS: Array[StringName] = [&"direct", &"sweeping"]

var failures: PackedStringArray = PackedStringArray()
var checks: int = 0

var main: Control = null
var ducts: DuctView = null
var collector: CollectorView = null
var receipt: MathReceipt = null
var math_button: Button = null


func _initialize() -> void:
	_start.call_deferred()


func _start() -> void:
	main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame

	ducts = main.get_node("Shop/Ducts")
	collector = main.get_node("Shop/Collector")
	receipt = main.get_node("Hud/MathReceipt")
	math_button = main.get_node("Hud/RightColumn/ProposalPanel/Content/MathButton")

	_check_empty_screen()
	_check_collector_choice()
	_check_every_route_draws_a_connected_branch()
	_check_partial_networks()
	_check_route_change_replaces_geometry()
	await _check_receipt_availability()
	await _check_receipt_pause_restoration()
	await _check_restart_clears_everything()

	_report()


func _check_empty_screen() -> void:
	main.reset_run()
	_equal(ducts.active_runs().size(), 0, "empty screen draws no duct")
	_true(collector.current_collector() == null, "empty screen draws no collector")
	_true(math_button.disabled, "receipt available on an empty proposal")
	_true(not receipt.is_open(), "receipt open on an empty proposal")
	_equal(main.calculation.total_airflow_cfm(), 0.0, "empty screen carries no air")


func _check_collector_choice() -> void:
	for collector_id: StringName in [&"budget", &"balanced", &"powerful"]:
		main.choose_collector(collector_id)
		var shown: CollectorDefinition = collector.current_collector()
		_true(shown != null, "%s drew no collector" % collector_id)
		if shown != null:
			_equal(shown.collector_id, collector_id, "collector on the pad")
			_true(shown.silhouette_height_px() > 0.0, "%s has a silhouette" % collector_id)

	# Changing collector must not disturb route choices.
	main.select_machine(&"table_saw")
	main.choose_route(&"direct")
	main.choose_collector(&"powerful")
	_true(main.proposal.route_for(&"table_saw") != null, "changing collector dropped a route")
	_equal(
		main.proposal.route_for(&"table_saw").route_id, &"direct",
		"changing collector altered a route"
	)


## Every machine and route pair must put its own geometry on screen, and the
## selected machine's branch must be the highlighted one.
func _check_every_route_draws_a_connected_branch() -> void:
	for machine_id: StringName in MACHINE_IDS:
		for route_id: StringName in ROUTE_IDS:
			main.reset_run()
			main.choose_collector(&"balanced")
			main.select_machine(machine_id)
			main.choose_route(route_id)

			var label: String = "%s/%s" % [machine_id, route_id]
			var branch: DuctBranchDefinition = main._branch_for(machine_id, route_id)
			_true(branch != null, "%s has no geometry" % label)
			if branch == null:
				continue

			for run: DuctRunDefinition in branch.all_runs():
				_true(ducts.has_run(run.run_id), "%s run %s not drawn" % [label, run.run_id])
				_true(
					ducts.highlighted_run_ids().has(run.run_id),
					"%s run %s not highlighted while selected" % [label, run.run_id]
				)

			# Only this machine's ductwork is on screen.
			for other_id: StringName in MACHINE_IDS:
				if other_id == machine_id:
					continue
				var other: DuctBranchDefinition = main._branch_for(other_id, &"direct")
				_true(
					not ducts.has_run(other.branch_run.run_id),
					"%s drew %s's branch too" % [label, other_id]
				)

			# The trunk to the collector is always present once air is moving.
			_true(ducts.has_run(&"main_9_run"), "%s left no trunk to the collector" % label)


func _check_partial_networks() -> void:
	# Saw and planer only: the seven-inch main is fed, and the trunk continues.
	main.reset_run()
	main.choose_collector(&"balanced")
	main.select_machine(&"table_saw")
	main.choose_route(&"direct")
	main.select_machine(&"planer")
	main.choose_route(&"direct")
	_true(ducts.has_run(&"main_7_run"), "seven-inch main missing for saw and planer")
	_true(ducts.has_run(&"main_9_run"), "trunk missing for saw and planer")
	_equal(main.calculation.total_airflow_cfm(), 1000.0, "saw and planer carry 1,000 CFM")
	_true(not main.proposal.is_complete(), "two machines reported a complete proposal")

	# Sander only: nothing feeds the seven-inch main, so it must not appear.
	main.reset_run()
	main.choose_collector(&"balanced")
	main.select_machine(&"wide_belt_sander")
	main.choose_route(&"sweeping")
	_true(not ducts.has_run(&"main_7_run"), "seven-inch main drawn with nothing feeding it")
	_true(ducts.has_run(&"main_9_run"), "trunk missing for the sander alone")
	_equal(main.calculation.total_airflow_cfm(), 800.0, "sander alone carries 800 CFM")

	# All three: one continuous network at the full airflow.
	main.select_machine(&"table_saw")
	main.choose_route(&"direct")
	main.select_machine(&"planer")
	main.choose_route(&"sweeping")
	_true(main.proposal.is_complete(), "three routes did not complete the proposal")
	_true(ducts.has_run(&"main_7_run") and ducts.has_run(&"main_9_run"), "mains missing")
	_equal(main.calculation.total_airflow_cfm(), 1800.0, "complete network carries 1,800 CFM")


## Switching a route must swap that branch's geometry, not stack both.
func _check_route_change_replaces_geometry() -> void:
	main.reset_run()
	main.choose_collector(&"balanced")
	main.select_machine(&"planer")
	main.choose_route(&"direct")

	var direct: DuctBranchDefinition = main._branch_for(&"planer", &"direct")
	var sweeping: DuctBranchDefinition = main._branch_for(&"planer", &"sweeping")
	_true(ducts.has_run(direct.branch_run.run_id), "direct branch not drawn")
	_true(not ducts.has_run(sweeping.branch_run.run_id), "sweeping branch drawn too early")

	main.choose_route(&"sweeping")
	_true(ducts.has_run(sweeping.branch_run.run_id), "sweeping branch not drawn after change")
	_true(not ducts.has_run(direct.branch_run.run_id), "direct branch survived the change")

	# Other machines keep their own geometry through the change.
	main.select_machine(&"table_saw")
	main.choose_route(&"direct")
	main.select_machine(&"planer")
	main.choose_route(&"direct")
	_true(
		ducts.has_run(main._branch_for(&"table_saw", &"direct").branch_run.run_id),
		"changing the planer dropped the saw's branch"
	)


func _check_receipt_availability() -> void:
	main.reset_run()
	_true(math_button.disabled, "receipt available with nothing chosen")

	main.choose_collector(&"balanced")
	_true(math_button.disabled, "receipt available with only a collector")

	main.select_machine(&"table_saw")
	main.choose_route(&"direct")
	main.select_machine(&"planer")
	main.choose_route(&"direct")
	await process_frame
	_true(math_button.disabled, "receipt available with one machine unrouted")

	# Asking for the receipt early must be refused rather than opening empty.
	main.open_math_receipt()
	_true(not receipt.is_open(), "receipt opened on an incomplete proposal")

	main.select_machine(&"wide_belt_sander")
	main.choose_route(&"direct")
	await process_frame
	_true(not math_button.disabled, "receipt still unavailable when complete")


func _check_receipt_pause_restoration() -> void:
	# Opening from a running clock pauses it; closing resumes it.
	_true(not root.get_tree().paused, "run already paused before the receipt")
	main.open_math_receipt()
	await process_frame
	_true(receipt.is_open(), "receipt did not open when complete")
	_true(root.get_tree().paused, "receipt did not pause the countdown")

	main.close_math_receipt()
	await process_frame
	_true(not receipt.is_open(), "receipt did not close")
	_true(not root.get_tree().paused, "closing the receipt left the run paused")

	# Opening from an already-paused run must leave it paused afterwards.
	main._on_pause_pressed()
	_true(root.get_tree().paused, "manual pause failed")
	main.open_math_receipt()
	await process_frame
	_true(root.get_tree().paused, "receipt unpaused a paused run")
	main.close_math_receipt()
	await process_frame
	_true(root.get_tree().paused, "closing the receipt resumed a run the player had paused")

	main._on_pause_pressed()
	_true(not root.get_tree().paused, "could not resume after using the receipt")


func _check_restart_clears_everything() -> void:
	main.choose_collector(&"powerful")
	main.select_machine(&"table_saw")
	main.choose_route(&"sweeping")
	main.open_math_receipt()
	await process_frame
	_true(receipt.is_open() or not main.proposal.is_complete(), "receipt state before restart")

	main.remaining_seconds = 42.0
	main._on_restart_pressed()
	await process_frame

	_true(not receipt.is_open(), "restart left the receipt open")
	_true(not root.get_tree().paused, "restart left the run paused")
	_equal(ducts.active_runs().size(), 0, "restart left ductwork on screen")
	_equal(ducts.highlighted_run_ids().size(), 0, "restart left a highlighted branch")
	_true(collector.current_collector() == null, "restart left a collector on the pad")
	_equal(main.calculation.total_airflow_cfm(), 0.0, "restart left airflow in the network")
	_true(math_button.disabled, "restart left the receipt available")
	_true(not main.proposal.has_collector(), "restart left the proposal collector")
	_equal(main.proposal.total_cost(), 0, "restart left a cost")
	_equal(main.selected_machine_id, &"", "restart left a machine selected")
	_true(main.remaining_seconds > 599.0, "restart did not reset the clock")


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
		print("DESIGN SCREEN TESTS PASSED (%d checks)" % checks)
		quit(0)
		return

	print("DESIGN SCREEN TESTS FAILED (%d of %d checks)" % [failures.size(), checks])
	for failure: String in failures:
		print("  - " + failure)
	quit(1)
