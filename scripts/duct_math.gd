class_name DuctMath
extends RefCounted

## Round-duct formulas from `docs/ENGINEERING_MODEL.md`.
##
## Every function returns full precision; rounding belongs to display code
## only. Units are never implicit: each function names the unit it takes and
## the unit it returns.

const INCHES_PER_FOOT: float = 12.0
## Standard-air constant in VP = (V / 4005)², velocity pressure in inches w.g.
const STANDARD_AIR_CONSTANT: float = 4005.0


static func diameter_feet(diameter_inches: float) -> float:
	return diameter_inches / INCHES_PER_FOOT


## A = π × D² ÷ 4, with D in feet, returning square feet.
static func round_area_square_feet(diameter_inches: float) -> float:
	var diameter: float = diameter_feet(diameter_inches)
	return PI * diameter * diameter / 4.0


## V = Q ÷ A, returning feet per minute.
static func velocity_fpm(airflow_cfm: float, diameter_inches: float) -> float:
	var area: float = round_area_square_feet(diameter_inches)
	if area <= 0.0:
		return 0.0
	return airflow_cfm / area


## VP = (V ÷ 4005)² for standard air, returning inches water gauge.
static func velocity_pressure_inwg(velocity: float) -> float:
	var ratio: float = velocity / STANDARD_AIR_CONSTANT
	return ratio * ratio


## Q = V × A, the inverse used to check the relationship in tests.
static func airflow_cfm(velocity: float, diameter_inches: float) -> float:
	return velocity * round_area_square_feet(diameter_inches)
