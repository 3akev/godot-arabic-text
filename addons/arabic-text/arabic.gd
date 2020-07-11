const reshaper = preload('res://addons/arabic-text/reshaper/arabic_reshaper.gd')
const bidi = preload("res://addons/arabic-text/bidi/algorithm.gd")

static func process_text(text):
	return bidi.get_display(reshaper.reshape(text))
