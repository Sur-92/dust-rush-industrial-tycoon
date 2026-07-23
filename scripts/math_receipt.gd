class_name MathReceipt
extends Control

## The optional "Show the math" drawer.
##
## It explains the network the player actually chose. It formats values that
## `DuctCalculation` produced and never performs engineering arithmetic itself,
## so what the player reads cannot drift from what the game computed.

signal close_requested

const HEADING_COLOR: Color = Color(0.957, 0.659, 0.267)
const BODY_COLOR: Color = Color(0.69, 0.749, 0.82)
const VALUE_COLOR: Color = Color(0.953, 0.969, 0.984)
const MUTED_COLOR: Color = Color(0.588, 0.639, 0.71)
const CAUTION_COLOR: Color = Color(0.902, 0.639, 0.404)

const HEADING_SIZE: int = 15
const BODY_SIZE: int = 13
const SMALL_SIZE: int = 12

@onready var _sections: VBoxContainer = $Backdrop/Frame/Layout/Scroll/Sections
@onready var _scroll: ScrollContainer = $Backdrop/Frame/Layout/Scroll


func _ready() -> void:
	visible = false


func is_open() -> bool:
	return visible


func open(
	calculation: DuctCalculation,
	proposal: SystemProposal,
	machines: Array[MachineDefinition]
) -> void:
	_rebuild(calculation, proposal, machines)
	visible = true
	_scroll.scroll_vertical = 0


func close() -> void:
	visible = false


func _on_close_pressed() -> void:
	close_requested.emit()


func _rebuild(
	calculation: DuctCalculation,
	proposal: SystemProposal,
	machines: Array[MachineDefinition]
) -> void:
	for child: Node in _sections.get_children():
		child.queue_free()

	_design_basis(machines)
	_flow_math(calculation)
	_duct_steps(calculation)
	_not_evaluated()
	_gameplay_result(proposal)


## 1. Design basis — where each machine's airflow number comes from.
func _design_basis(machines: Array[MachineDefinition]) -> void:
	_heading("1. Design basis")
	_body(
		"Each machine's airflow is a scenario input for this fictional shop, not a "
		+ "universal requirement for every machine of that type."
	)
	for machine: MachineDefinition in machines:
		_row(
			"%s — %s" % [machine.display_name, machine.pickup_summary()],
			"%s CFM" % GameFormat.integer(machine.airflow_cfm)
		)
		if machine.airflow_source != null:
			_note(
				"%s. %s"
				% [
					EngineeringSource.classification_label(
						machine.airflow_source.classification
					),
					machine.airflow_source.basis,
				]
			)
			_note("Source read %s: %s" % [machine.airflow_source.accessed, machine.airflow_source.url])


## 2. Flow math — what is added at each junction.
func _flow_math(calculation: DuctCalculation) -> void:
	_heading("2. Flow math")
	_body("Airflow adds up as branches merge on the way to the collector.")
	for transition: DuctCalculation.Transition in calculation.transitions():
		_row(transition.display_name, transition.airflow_sum_text())
		_note(transition.explanation)


## 3. Duct steps — diameter, area, velocity and velocity pressure per segment.
func _duct_steps(calculation: DuctCalculation) -> void:
	_heading("3. Duct steps")
	_body(
		"Round duct area is A = π × D² ÷ 4 with the diameter in feet. "
		+ "Velocity is V = Q ÷ A. Velocity pressure for standard air is VP = (V ÷ 4005)²."
	)

	for segment: DuctCalculation.Segment in calculation.machine_segments():
		_segment_row(segment)
	for transition: DuctCalculation.Transition in calculation.transitions():
		_segment_row(transition.outlet)


func _segment_row(segment: DuctCalculation.Segment) -> void:
	_row(
		"%s — %s-inch" % [segment.label, GameFormat.trim_number(segment.diameter_inches)],
		"%s CFM" % GameFormat.integer(segment.airflow_cfm)
	)
	_note(
		"%s in ÷ 12 = %s ft · area %s sq ft · %s FPM · VP %s in w.g."
		% [
			GameFormat.trim_number(segment.diameter_inches),
			GameFormat.decimal(DuctMath.diameter_feet(segment.diameter_inches), 3),
			GameFormat.decimal(segment.area_square_feet, 3),
			GameFormat.integer(segment.velocity_fpm),
			GameFormat.decimal(segment.velocity_pressure_inwg, 2),
		]
	)


## 4. The honest limits of this receipt.
func _not_evaluated() -> void:
	_heading("4. Not yet evaluated")
	_caution(
		"Static-pressure loss and the collector operating point are not calculated here. "
		+ "This ticket does not include verified straight-duct lengths, fitting geometry, "
		+ "loss coefficients, or fan curves, so none are invented."
	)
	_caution(
		"A collector's headline capacity does not prove it moves 1,800 CFM against this "
		+ "system's resistance. Nothing above makes this design code-compliant or a "
		+ "substitute for a qualified engineer."
	)


## 5. The abstract gameplay layer, kept clearly separate from the engineering.
func _gameplay_result(proposal: SystemProposal) -> void:
	_heading("5. Gameplay result")
	_body("These are the abstract game values that decide the run, not engineering output.")
	_row("Expected fit", SystemProposal.fit_label(proposal.fit()))
	_row("Machine demand", "%d game units" % proposal.total_demand())
	_row("Collector capacity", "%d game units" % proposal.collector_capacity())
	_row("Route restriction", str(proposal.total_restriction()))
	_row("Capacity margin", GameFormat.signed(proposal.capacity_margin()))
	_row("Proposal cost", GameFormat.money(proposal.total_cost()))
	_row("Installation time", GameFormat.seconds(proposal.total_install_seconds()))


func _heading(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", HEADING_COLOR)
	label.add_theme_font_size_override("font_size", HEADING_SIZE)
	label.custom_minimum_size = Vector2(0.0, 26.0)
	label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_sections.add_child(label)


func _body(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", BODY_COLOR)
	label.add_theme_font_size_override("font_size", BODY_SIZE)
	_sections.add_child(label)


func _caution(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", CAUTION_COLOR)
	label.add_theme_font_size_override("font_size", BODY_SIZE)
	_sections.add_child(label)


func _row(caption: String, value: String) -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 12)

	var caption_label: Label = Label.new()
	caption_label.text = caption
	caption_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	caption_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	caption_label.add_theme_color_override("font_color", BODY_COLOR)
	caption_label.add_theme_font_size_override("font_size", BODY_SIZE)

	var value_label: Label = Label.new()
	value_label.text = value
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_color_override("font_color", VALUE_COLOR)
	value_label.add_theme_font_size_override("font_size", BODY_SIZE)

	row.add_child(caption_label)
	row.add_child(value_label)
	_sections.add_child(row)


func _note(text: String) -> void:
	var label: Label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", MUTED_COLOR)
	label.add_theme_font_size_override("font_size", SMALL_SIZE)
	_sections.add_child(label)
