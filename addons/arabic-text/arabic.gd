tool

const reshaper = preload('res://addons/arabic-text/reshaper/arabic_reshaper.gd')
const UBA = preload("res://addons/arabic-text/UBA/UBA.gd")

static func process_text(text):
	if text.empty(): return text
	return UBA.display(reshaper.reshape(text))
