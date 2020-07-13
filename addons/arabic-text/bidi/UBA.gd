# Unicode Bidirectional Algorithm
# https://unicode.org/reports/tr9/

const unicodedata = preload("res://addons/arabic-text/bidi/unicodedata.gd")

const max_depth = 125

static func get_paragraph_level(paragraph: String) -> int:
	# P2 - P3
	for ch in paragraph:
		var bidi_class = unicodedata.bidirectional(ch)
		if bidi_class in ["AL", "R"]:
			return 1
		elif bidi_class in ["L"]:
			return 0
	return 0

static func display_paragraph(paragraph: String) -> String:
	var level = get_paragraph_level(paragraph)
	return paragraph

static func display(text: String) -> String:
	# P1
	var result = PoolStringArray()
	for paragraph in text.split("\n"):
		result.append(display_paragraph(paragraph))
	return result.join("\n")
