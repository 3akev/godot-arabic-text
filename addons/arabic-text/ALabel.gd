tool
extends Label

var reshaper = preload('res://addons/arabic-text/reshaper/arabic_reshaper.gd').new()
var bidi = preload("res://addons/arabic-text/bidi/algorithm.gd").new()

var prev_text = ''

# Use this for input rather than `text`
export(String, MULTILINE) var arabic_input = '' setget _set_arabic_input

func _set_arabic_input(s):
	arabic_input = s
	_on_ALabel_draw()

func display():
	text = bidi.get_display(reshaper.reshape(arabic_input))

func _ready():
	display()
	connect("draw", self, "_on_ALabel_draw")

func _on_ALabel_draw():
	if arabic_input != prev_text:
		display()
		prev_text = arabic_input
