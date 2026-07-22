extends Control

## Run controller for the cabinet-shop design screen.
##
## Owns the run clock, the selected machine, and the system proposal. The shop
## views, collector cards, route buttons, and panels only report intent and
## present whatever state this controller hands back.

const RUN_SECONDS: float = 600.0
const STATUS_DESIGNING: String = "Cabinet shop — choose a collector and a route for every machine."
const STATUS_PAUSED: String = "Run paused."
const STATUS_FINISHED: String = "Time! Committing the proposal arrives with a later ticket."

@onready var timer_label: Label = $Hud/TopBar/TimerLabel
@onready var status_label: Label = $Hud/StatusLabel
@onready var pause_button: Button = $Hud/TopBar/PauseButton
@onready var machines_root: Node2D = $Shop/Machines
@onready var collector_cards_root: HBoxContainer = $Hud/CollectorSection/Cards
@onready var info_panel: MachineInfoPanel = $Hud/RightColumn/MachinePanel
@onready var proposal_panel: ProposalPanel = $Hud/RightColumn/ProposalPanel

var remaining_seconds: float = RUN_SECONDS
var run_finished: bool = false
var selected_machine_id: StringName = &""
var proposal: SystemProposal = SystemProposal.new()

var _machine_views: Array[MachineView] = []
var _collector_cards: Array[CollectorCard] = []
var _routes_by_id: Dictionary[StringName, RouteDefinition] = {}
var _collectors_by_id: Dictionary[StringName, CollectorDefinition] = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_collect_machine_views()
	_collect_collector_cards()
	_collect_route_definitions()
	proposal.set_machines(_machine_definitions())
	reset_run()


func _process(delta: float) -> void:
	if get_tree().paused or run_finished:
		return

	remaining_seconds = maxf(remaining_seconds - delta, 0.0)
	update_timer_label()

	if is_zero_approx(remaining_seconds):
		finish_run()


func _on_pause_pressed() -> void:
	if run_finished:
		return

	get_tree().paused = not get_tree().paused
	pause_button.text = "Resume" if get_tree().paused else "Pause"
	status_label.text = STATUS_PAUSED if get_tree().paused else STATUS_DESIGNING


func _on_restart_pressed() -> void:
	reset_run()


func reset_run() -> void:
	get_tree().paused = false
	remaining_seconds = RUN_SECONDS
	run_finished = false
	pause_button.disabled = false
	pause_button.text = "Pause"
	status_label.text = STATUS_DESIGNING
	selected_machine_id = &""
	proposal.clear()
	refresh_design()
	update_timer_label()


func finish_run() -> void:
	run_finished = true
	get_tree().paused = true
	pause_button.disabled = true
	status_label.text = STATUS_FINISHED


func update_timer_label() -> void:
	var total_seconds: int = ceili(remaining_seconds)
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]


func select_machine(machine_id: StringName) -> void:
	selected_machine_id = machine_id
	refresh_design()


func choose_collector(collector_id: StringName) -> void:
	var definition: CollectorDefinition = _collectors_by_id.get(collector_id)
	if definition == null:
		return

	proposal.collector = definition
	refresh_design()


## Routes apply to the machine the player is currently inspecting, so a route
## click without a selected machine is ignored rather than guessed at.
func choose_route(route_id: StringName) -> void:
	if selected_machine_id == &"":
		return

	var definition: RouteDefinition = _routes_by_id.get(route_id)
	if definition == null:
		return

	proposal.set_route(selected_machine_id, definition)
	refresh_design()


## Pushes the whole design state back out to every presentation surface.
func refresh_design() -> void:
	var selected_definition: MachineDefinition = null

	for view: MachineView in _machine_views:
		var machine: MachineDefinition = view.definition
		if machine == null:
			continue
		var is_selected: bool = machine.machine_id == selected_machine_id
		view.set_selected(is_selected)
		view.set_route(proposal.route_for(machine.machine_id))
		if is_selected:
			selected_definition = machine

	for card: CollectorCard in _collector_cards:
		card.set_chosen(
			proposal.has_collector()
			and card.definition.collector_id == proposal.collector.collector_id
		)

	if selected_definition == null:
		info_panel.show_empty()
	else:
		info_panel.show_machine(
			selected_definition, proposal.route_for(selected_definition.machine_id)
		)

	proposal_panel.show_proposal(proposal)


func _machine_definitions() -> Array[MachineDefinition]:
	var definitions: Array[MachineDefinition] = []
	for view: MachineView in _machine_views:
		if view.definition != null:
			definitions.append(view.definition)
	return definitions


func _collect_machine_views() -> void:
	for child: Node in machines_root.get_children():
		var view := child as MachineView
		if view == null:
			continue
		_machine_views.append(view)
		view.selection_requested.connect(select_machine)


func _collect_collector_cards() -> void:
	for child: Node in collector_cards_root.get_children():
		var card := child as CollectorCard
		if card == null or card.definition == null:
			continue
		_collector_cards.append(card)
		_collectors_by_id[card.definition.collector_id] = card.definition
		card.chosen.connect(choose_collector)


func _collect_route_definitions() -> void:
	for definition: RouteDefinition in info_panel.route_definitions():
		_routes_by_id[definition.route_id] = definition
	info_panel.route_chosen.connect(choose_route)
