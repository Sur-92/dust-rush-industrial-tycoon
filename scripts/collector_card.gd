class_name CollectorCard
extends Button

## One collector choice. The card renders its definition and reports a click as
## intent; the run controller decides which collector the proposal holds.

signal chosen(collector_id: StringName)

@export var definition: CollectorDefinition

@onready var _name_label: Label = $Content/Header/CollectorName
@onready var _capacity_label: Label = $Content/Header/Capacity
@onready var _stats_label: Label = $Content/Stats
@onready var _tradeoff_label: Label = $Content/Tradeoff


func _ready() -> void:
	if definition == null:
		push_error("CollectorCard '%s' has no CollectorDefinition assigned." % name)
		disabled = true
		return

	toggle_mode = true
	_name_label.text = definition.display_name
	_capacity_label.text = "%d capacity" % definition.capacity
	_stats_label.text = "%s · %s install" % [
		GameFormat.money(definition.equipment_cost),
		GameFormat.seconds(definition.install_seconds),
	]
	_tradeoff_label.text = definition.tradeoff
	pressed.connect(_on_pressed)


func set_chosen(value: bool) -> void:
	set_pressed_no_signal(value)


func _on_pressed() -> void:
	chosen.emit(definition.collector_id)
