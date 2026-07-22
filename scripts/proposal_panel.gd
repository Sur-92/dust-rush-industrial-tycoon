class_name ProposalPanel
extends PanelContainer

## Live review of the current proposal. Reads the proposal's own values so the
## formulas stay in one place; it performs no gameplay arithmetic itself.

signal math_requested

const UNKNOWN: String = "—"

const READY_COLOR: Color = Color(0.588, 0.827, 0.722)
const INCOMPLETE_COLOR: Color = Color(0.957, 0.659, 0.267)
const SHORT_COLOR: Color = Color(0.902, 0.451, 0.404)
const TIGHT_COLOR: Color = Color(0.957, 0.659, 0.267)
const COMFORTABLE_COLOR: Color = Color(0.588, 0.827, 0.722)
const VALUE_COLOR: Color = Color(0.953, 0.969, 0.984)

@onready var _demand_value: Label = $Content/Grid/DemandValue
@onready var _capacity_value: Label = $Content/Grid/CapacityValue
@onready var _restriction_value: Label = $Content/Grid/RestrictionValue
@onready var _usable_value: Label = $Content/Grid/UsableValue
@onready var _margin_value: Label = $Content/Grid/MarginValue
@onready var _fit_value: Label = $Content/Grid/FitValue
@onready var _expansion_value: Label = $Content/Grid/ExpansionValue
@onready var _cost_value: Label = $Content/Grid/CostValue
@onready var _time_value: Label = $Content/Grid/TimeValue
@onready var _status_label: Label = $Content/Status
@onready var _math_button: Button = $Content/MathButton


func _ready() -> void:
	_math_button.pressed.connect(func() -> void: math_requested.emit())


func show_proposal(proposal: SystemProposal) -> void:
	var known: bool = proposal.has_collector()

	_demand_value.text = str(proposal.total_demand())
	_restriction_value.text = str(proposal.total_restriction())
	_capacity_value.text = str(proposal.collector_capacity()) if known else UNKNOWN
	_usable_value.text = str(proposal.usable_capacity()) if known else UNKNOWN
	_margin_value.text = GameFormat.signed(proposal.capacity_margin()) if known else UNKNOWN
	_expansion_value.text = str(proposal.expansion_room()) if known else UNKNOWN
	_cost_value.text = GameFormat.money(proposal.total_cost())
	_time_value.text = GameFormat.seconds(proposal.total_install_seconds())

	var fit: SystemProposal.Fit = proposal.fit()
	_fit_value.text = SystemProposal.fit_label(fit)
	_fit_value.add_theme_color_override("font_color", _fit_color(fit))

	var complete: bool = proposal.is_complete()
	# The receipt explains one exact network, so it stays unavailable until the
	# player has actually chosen that network.
	_math_button.disabled = not complete
	_status_label.text = proposal.completion_text()
	_status_label.add_theme_color_override(
		"font_color", READY_COLOR if complete else INCOMPLETE_COLOR
	)


func _fit_color(fit: SystemProposal.Fit) -> Color:
	match fit:
		SystemProposal.Fit.SHORT:
			return SHORT_COLOR
		SystemProposal.Fit.TIGHT:
			return TIGHT_COLOR
		SystemProposal.Fit.COMFORTABLE:
			return COMFORTABLE_COLOR
	return VALUE_COLOR
