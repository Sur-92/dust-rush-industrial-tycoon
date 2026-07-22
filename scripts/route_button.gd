class_name RouteButton
extends Button

## One route approach offered for the selected machine. Reports a click as
## intent; the run controller decides which machine the route lands on.

signal chosen(route_id: StringName)

@export var definition: RouteDefinition

@onready var _name_label: Label = $Content/RouteName
@onready var _stats_label: Label = $Content/RouteStats


func _ready() -> void:
	if definition == null:
		push_error("RouteButton '%s' has no RouteDefinition assigned." % name)
		disabled = true
		return

	toggle_mode = true
	_name_label.text = definition.display_name
	_stats_label.text = "%s restriction\n%s · %s" % [
		GameFormat.signed(definition.restriction),
		GameFormat.money(definition.cost),
		GameFormat.seconds(definition.install_seconds),
	]
	pressed.connect(_on_pressed)


func set_chosen(value: bool) -> void:
	set_pressed_no_signal(value)


func _on_pressed() -> void:
	chosen.emit(definition.route_id)
