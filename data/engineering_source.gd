class_name EngineeringSource
extends Resource

## Provenance for one engineering value, following the source policy in
## `docs/ENGINEERING_MODEL.md`. Citations live in data like this rather than in
## UI scripts, so a value can never be shown without its classification.

enum Classification {
	SCENARIO_INPUT, ## Supplied by the fictional customer or machine OEM.
	DERIVED_VALUE, ## Calculated from displayed inputs with a documented formula.
	REFERENCE_VALUE, ## Coefficient or criterion tied to a named authoritative source.
	GAMEPLAY_SIMPLIFICATION, ## Deliberate approximation, excluded from real-world claims.
}

@export var classification: Classification = Classification.SCENARIO_INPUT
@export_multiline var basis: String = ""
@export var url: String = ""
## ISO date the source was read, so a stale citation is visible.
@export var accessed: String = ""


static func classification_label(value: Classification) -> String:
	match value:
		Classification.SCENARIO_INPUT:
			return "Scenario input"
		Classification.DERIVED_VALUE:
			return "Derived value"
		Classification.REFERENCE_VALUE:
			return "Reference value"
		Classification.GAMEPLAY_SIMPLIFICATION:
			return "Gameplay simplification"
	return "Unclassified"
