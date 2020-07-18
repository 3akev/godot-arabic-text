const statics = preload("res://addons/arabic-text/UBA/statics.gd")
const unicodedata = preload("res://addons/arabic-text/UBA/database/unicodedata.gd")

static func preprocess_text(text):
	# preprocess paragraph once and for all, get characters and bidi types
	var ls = []
	for ch in text:
		var struct = statics._get_char_struct()
		struct['ch'] = ch
		struct['bidi_type'] = unicodedata.bidirectional(ch)
		ls.append(struct)
	return ls

static func get_paragraph_level(data) -> int:
	# P2 - P3
	for ch in data['chars']:
		var bidi_type = ch['bidi_type']
		if bidi_type in ["AL", "R"]:
			return 1
		elif bidi_type in ["L"]:
			return 0
	return 0
