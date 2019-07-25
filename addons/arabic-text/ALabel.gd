extends Label

var reshaper = preload('res://addons/arabic-text/reshaper/arabic_reshaper.gd').new()
var bidi = preload("res://addons/arabic-text/bidi/algorithm.gd").new()

var prev_text = ''

func display():
	text = bidi.get_display(reshaper.reshape(text))

func _ready():
	display()
	connect("draw", self, "_on_ALabel_draw")

func _on_ALabel_draw():
	if text != prev_text:
		display()
		prev_text = text
