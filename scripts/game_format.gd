class_name GameFormat
extends RefCounted

## Shared player-facing formatting, so cards, panels, and the engineering
## receipt all read the same way.
##
## Everything here is display only. Calculations keep full precision; these
## helpers are the single place where a value is rounded for a label.


static func money(amount: int) -> String:
	return ("-$" if amount < 0 else "$") + group_digits(str(absi(amount)))


static func seconds(value: int) -> String:
	return "%d sec" % value


static func signed(value: int) -> String:
	return "+%d" % value if value > 0 else str(value)


## Whole number with thousands separators, for CFM and FPM readouts.
static func integer(value: float) -> String:
	var rounded: int = roundi(value)
	return ("-" if rounded < 0 else "") + group_digits(str(absi(rounded)))


## Fixed decimal places, for areas and pressures.
static func decimal(value: float, places: int) -> String:
	return String.num(value, places)


## Drops a trailing ".0" so a 4.0-inch duct reads as "4-inch".
static func trim_number(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(roundi(value))
	return String.num(value, 1)


static func group_digits(digits: String) -> String:
	var grouped: String = ""
	var counted: int = 0

	for index: int in range(digits.length() - 1, -1, -1):
		grouped = digits[index] + grouped
		counted += 1
		if counted % 3 == 0 and index > 0:
			grouped = "," + grouped

	return grouped
