extends Control

const RUN_SECONDS: float = 600.0

@onready var timer_label: Label = $Margin/Content/TimerLabel
@onready var status_label: Label = $Margin/Content/StatusLabel
@onready var pause_button: Button = $Margin/Content/Controls/PauseButton

var remaining_seconds: float = RUN_SECONDS
var run_finished: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
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
	status_label.text = "Run paused." if get_tree().paused else "Scaffold running — first customer is the next ticket."


func _on_restart_pressed() -> void:
	reset_run()


func reset_run() -> void:
	get_tree().paused = false
	remaining_seconds = RUN_SECONDS
	run_finished = false
	pause_button.disabled = false
	pause_button.text = "Pause"
	status_label.text = "Scaffold running — first customer is the next ticket."
	update_timer_label()


func finish_run() -> void:
	run_finished = true
	get_tree().paused = true
	pause_button.disabled = true
	status_label.text = "Time! Scoring will arrive with the playable slice."


func update_timer_label() -> void:
	var total_seconds: int = ceili(remaining_seconds)
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]
