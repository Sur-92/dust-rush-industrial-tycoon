extends SceneTree

## Deterministic checks for the proposal rules in `scripts/system_proposal.gd`.
##
## Plain Godot, no third-party framework. Run with:
##   godot --headless --path . -s res://tests/test_proposal.gd
## Exits non-zero when any check fails, so it can gate a change.

const MACHINE_PATHS: Array[String] = [
	"res://data/machines/table_saw.tres",
	"res://data/machines/planer.tres",
	"res://data/machines/wide_belt_sander.tres",
]

var failures: PackedStringArray = PackedStringArray()
var checks: int = 0


func _initialize() -> void:
	var machines: Array[MachineDefinition] = []
	for path: String in MACHINE_PATHS:
		machines.append(load(path) as MachineDefinition)

	var budget: CollectorDefinition = load("res://data/collectors/budget.tres")
	var balanced: CollectorDefinition = load("res://data/collectors/balanced.tres")
	var powerful: CollectorDefinition = load("res://data/collectors/powerful.tres")
	var direct: RouteDefinition = load("res://data/routes/direct.tres")
	var sweeping: RouteDefinition = load("res://data/routes/sweeping.tres")

	_check_source_values(machines, budget, balanced, powerful, direct, sweeping)
	_check_demand(machines)
	_check_documented_fits(machines, budget, balanced, powerful, direct, sweeping)
	_check_totals(machines, balanced, powerful, direct, sweeping)
	_check_incomplete_proposals(machines, balanced, direct)
	_check_restart_clears(machines, balanced, direct)

	_report()


## The rules below are only meaningful if the shipped data still matches the
## approved gameplay values, so pin those first.
func _check_source_values(
	machines: Array[MachineDefinition],
	budget: CollectorDefinition,
	balanced: CollectorDefinition,
	powerful: CollectorDefinition,
	direct: RouteDefinition,
	sweeping: RouteDefinition
) -> void:
	_equal(machines[0].collection_demand, 2, "table saw demand")
	_equal(machines[1].collection_demand, 3, "planer demand")
	_equal(machines[2].collection_demand, 4, "wide-belt sander demand")

	_equal(budget.capacity, 8, "budget capacity")
	_equal(budget.equipment_cost, 8000, "budget cost")
	_equal(budget.install_seconds, 8, "budget install")
	_equal(balanced.capacity, 11, "balanced capacity")
	_equal(balanced.equipment_cost, 13000, "balanced cost")
	_equal(balanced.install_seconds, 12, "balanced install")
	_equal(powerful.capacity, 15, "powerful capacity")
	_equal(powerful.equipment_cost, 20000, "powerful cost")
	_equal(powerful.install_seconds, 18, "powerful install")

	_equal(direct.restriction, 1, "direct restriction")
	_equal(direct.cost, 500, "direct cost")
	_equal(direct.install_seconds, 2, "direct install")
	_equal(sweeping.restriction, 0, "sweeping restriction")
	_equal(sweeping.cost, 1000, "sweeping cost")
	_equal(sweeping.install_seconds, 4, "sweeping install")


func _check_demand(machines: Array[MachineDefinition]) -> void:
	var proposal: SystemProposal = _proposal(machines)
	_equal(proposal.total_demand(), 9, "total shop demand")


## The five fits the ticket documents, so the strategies stay distinguishable.
func _check_documented_fits(
	machines: Array[MachineDefinition],
	budget: CollectorDefinition,
	balanced: CollectorDefinition,
	powerful: CollectorDefinition,
	direct: RouteDefinition,
	sweeping: RouteDefinition
) -> void:
	var budget_smooth: SystemProposal = _proposal(machines, budget, [sweeping, sweeping, sweeping])
	_equal(budget_smooth.capacity_margin(), -1, "budget + sweeping margin")
	_fit(budget_smooth, SystemProposal.Fit.SHORT, "budget + three sweeping")

	var balanced_direct: SystemProposal = _proposal(machines, balanced, [direct, direct, direct])
	_equal(balanced_direct.capacity_margin(), -1, "balanced + direct margin")
	_fit(balanced_direct, SystemProposal.Fit.SHORT, "balanced + three direct")

	var balanced_mixed: SystemProposal = _proposal(machines, balanced, [direct, direct, sweeping])
	_equal(balanced_mixed.capacity_margin(), 0, "balanced + mixed margin")
	_fit(balanced_mixed, SystemProposal.Fit.TIGHT, "balanced + two direct and one sweeping")

	var balanced_smooth: SystemProposal = _proposal(machines, balanced, [sweeping, sweeping, sweeping])
	_equal(balanced_smooth.capacity_margin(), 2, "balanced + sweeping margin")
	_fit(balanced_smooth, SystemProposal.Fit.COMFORTABLE, "balanced + three sweeping")

	var powerful_direct: SystemProposal = _proposal(machines, powerful, [direct, direct, direct])
	_equal(powerful_direct.capacity_margin(), 3, "powerful + direct margin")
	_fit(powerful_direct, SystemProposal.Fit.COMFORTABLE, "powerful + three direct")

	# Budget must stay capacity-short however the routes are chosen.
	var budget_direct: SystemProposal = _proposal(machines, budget, [direct, direct, direct])
	_fit(budget_direct, SystemProposal.Fit.SHORT, "budget + three direct")

	# The tight band is 0..1 inclusive, so check its upper edge too.
	var balanced_one_direct: SystemProposal = _proposal(
		machines, balanced, [direct, sweeping, sweeping]
	)
	_equal(balanced_one_direct.capacity_margin(), 1, "balanced + one direct margin")
	_fit(balanced_one_direct, SystemProposal.Fit.TIGHT, "balanced + one direct")


func _check_totals(
	machines: Array[MachineDefinition],
	balanced: CollectorDefinition,
	powerful: CollectorDefinition,
	direct: RouteDefinition,
	sweeping: RouteDefinition
) -> void:
	var mixed: SystemProposal = _proposal(machines, balanced, [direct, direct, sweeping])
	_equal(mixed.total_restriction(), 2, "mixed restriction")
	_equal(mixed.usable_capacity(), 9, "mixed usable capacity")
	_equal(mixed.total_cost(), 15000, "mixed cost")
	_equal(mixed.total_install_seconds(), 20, "mixed install time")
	_equal(mixed.expansion_room(), 0, "mixed expansion room")

	var smooth: SystemProposal = _proposal(machines, balanced, [sweeping, sweeping, sweeping])
	_equal(smooth.total_cost(), 16000, "smooth cost")
	_equal(smooth.total_install_seconds(), 24, "smooth install time")
	_equal(smooth.expansion_room(), 2, "smooth expansion room")

	var strong: SystemProposal = _proposal(machines, powerful, [direct, direct, direct])
	_equal(strong.total_cost(), 21500, "powerful cost")
	_equal(strong.total_install_seconds(), 24, "powerful install time")
	_equal(strong.expansion_room(), 3, "powerful expansion room")

	# Expansion room never goes negative even when the fit is short.
	var short_fit: SystemProposal = _proposal(machines, balanced, [direct, direct, direct])
	_equal(short_fit.expansion_room(), 0, "short expansion room floor")

	# Totals accumulate as each route lands, not only when the proposal is done.
	var partial: SystemProposal = _proposal(machines, balanced)
	_equal(partial.total_cost(), 13000, "collector-only cost")
	_equal(partial.total_install_seconds(), 12, "collector-only install time")
	partial.set_route(machines[0].machine_id, direct)
	_equal(partial.total_cost(), 13500, "cost after one route")
	_equal(partial.total_install_seconds(), 14, "install time after one route")
	_equal(partial.total_restriction(), 1, "restriction after one route")

	# Changing a route replaces it rather than stacking another one.
	partial.set_route(machines[0].machine_id, sweeping)
	_equal(partial.total_cost(), 14000, "cost after changing that route")
	_equal(partial.total_restriction(), 0, "restriction after changing that route")


func _check_incomplete_proposals(
	machines: Array[MachineDefinition],
	balanced: CollectorDefinition,
	direct: RouteDefinition
) -> void:
	var empty: SystemProposal = _proposal(machines)
	_true(not empty.is_complete(), "empty proposal is incomplete")
	_true(empty.completion_text() != "Proposal ready", "empty proposal not reported ready")
	_fit(empty, SystemProposal.Fit.UNKNOWN, "empty proposal fit")
	_equal(empty.collector_capacity(), 0, "empty proposal capacity")

	var routes_only: SystemProposal = _proposal(machines, null, [direct, direct, direct])
	_true(not routes_only.is_complete(), "routes without a collector are incomplete")
	_true(
		routes_only.completion_text() != "Proposal ready",
		"routes without a collector not reported ready"
	)
	_fit(routes_only, SystemProposal.Fit.UNKNOWN, "routes-only fit")

	var collector_only: SystemProposal = _proposal(machines, balanced)
	_true(not collector_only.is_complete(), "collector without routes is incomplete")
	_equal(collector_only.machines_missing_routes().size(), 3, "three machines missing routes")

	var two_routes: SystemProposal = _proposal(machines, balanced)
	two_routes.set_route(machines[0].machine_id, direct)
	two_routes.set_route(machines[1].machine_id, direct)
	_true(not two_routes.is_complete(), "two of three routes is incomplete")
	_equal(two_routes.machines_missing_routes().size(), 1, "one machine missing a route")
	_true(
		two_routes.completion_text() != "Proposal ready",
		"partial routing not reported ready"
	)

	two_routes.set_route(machines[2].machine_id, direct)
	_true(two_routes.is_complete(), "all three routes completes the proposal")
	_equal(two_routes.completion_text(), "Proposal ready", "complete proposal reports ready")


func _check_restart_clears(
	machines: Array[MachineDefinition],
	balanced: CollectorDefinition,
	direct: RouteDefinition
) -> void:
	var proposal: SystemProposal = _proposal(machines, balanced, [direct, direct, direct])
	_true(proposal.is_complete(), "proposal complete before clear")

	proposal.clear()
	_true(not proposal.is_complete(), "clear leaves an incomplete proposal")
	_true(not proposal.has_collector(), "clear drops the collector")
	_equal(proposal.total_restriction(), 0, "clear drops the routes")
	_equal(proposal.total_cost(), 0, "clear drops the cost")
	_equal(proposal.total_install_seconds(), 0, "clear drops the install time")
	_equal(proposal.machines_missing_routes().size(), 3, "clear leaves every machine unrouted")
	_equal(proposal.total_demand(), 9, "clear keeps the shop machines")


func _proposal(
	machines: Array[MachineDefinition],
	collector: CollectorDefinition = null,
	routes: Array = []
) -> SystemProposal:
	var proposal: SystemProposal = SystemProposal.new()
	proposal.set_machines(machines)
	proposal.collector = collector
	for index: int in range(routes.size()):
		proposal.set_route(machines[index].machine_id, routes[index])
	return proposal


func _fit(proposal: SystemProposal, expected: SystemProposal.Fit, label: String) -> void:
	_equal(
		SystemProposal.fit_label(proposal.fit()),
		SystemProposal.fit_label(expected),
		"%s fit" % label
	)


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
		print("PROPOSAL TESTS PASSED (%d checks)" % checks)
		quit(0)
		return

	print("PROPOSAL TESTS FAILED (%d of %d checks)" % [failures.size(), checks])
	for failure: String in failures:
		print("  - " + failure)
	quit(1)
