extends Control

## Run controller for the cabinet-shop inspection view. It owns the run clock
## and the selected machine; the shop and HUD nodes only present that state.

const RUN_SECONDS: float = 600.0
const STATUS_INSPECTING: String = "Cabinet shop — click a machine to inspect it."
const STATUS_PAUSED: String = "Run paused."
const STATUS_FINISHED: String = "Time! Scoring arrives with a later ticket."

@onready var timer_label: Label = $Hud/TopBar/TimerLabel
@onready var status_label: Label = $Hud/StatusLabel
@onready var pause_button: Button = $Hud/TopBar/PauseButton
@onready var machines_root: Node2D = $Shop/Machines
@onready var info_panel: MachineInfoPanel = $Hud/InfoPanel

var remaining_seconds: float = RUN_SECONDS
var run_finished: bool = false
var selected_machine_id: StringName = &""

var _machine_views: Array[MachineView] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_collect_machine_views()
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
	status_label.text = STATUS_PAUSED if get_tree().paused else STATUS_INSPECTING


func _on_restart_pressed() -> void:
	reset_run()


func reset_run() -> void:
	get_tree().paused = false
	remaining_seconds = RUN_SECONDS
	run_finished = false
	pause_button.disabled = false
	pause_button.text = "Pause"
	status_label.text = STATUS_INSPECTING
	clear_selection()
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
	apply_selection()


func clear_selection() -> void:
	selected_machine_id = &""
	apply_selection()


func apply_selection() -> void:
	var selected_definition: MachineDefinition = null

	for view: MachineView in _machine_views:
		var is_selected: bool = (
			view.definition != null and view.definition.machine_id == selected_machine_id
		)
		view.set_selected(is_selected)
		if is_selected:
			selected_definition = view.definition

	if selected_definition == null:
		info_panel.show_empty()
	else:
		info_panel.show_machine(selected_definition)


func _collect_machine_views() -> void:
	for child: Node in machines_root.get_children():
		var view := child as MachineView
		if view == null:
			continue
		_machine_views.append(view)
		view.selection_requested.connect(_on_machine_selection_requested)


func _on_machine_selection_requested(machine_id: StringName) -> void:
	select_machine(machine_id)
