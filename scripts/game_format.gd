class_name GameFormat
extends RefCounted

## Shared player-facing number formatting, so cards, panels, and the proposal
## review all read the same way.


static func money(amount: int) -> String:
	var digits: String = str(absi(amount))
	var grouped: String = ""
	var counted: int = 0

	for index: int in range(digits.length() - 1, -1, -1):
		grouped = digits[index] + grouped
		counted += 1
		if counted % 3 == 0 and index > 0:
			grouped = "," + grouped

	return ("-$" if amount < 0 else "$") + grouped


static func seconds(value: int) -> String:
	return "%d sec" % value


static func signed(value: int) -> String:
	return "+%d" % value if value > 0 else str(value)
