tool
extends Label

const arabic = preload('res://addons/arabic-text/arabic.gd')

var prev_text = ''

# Use this for input rather than `text`
export(String, MULTILINE) var arabic_input = '' setget _set_arabic_input

func _set_arabic_input(s):
	arabic_input = s
	_on_ALabel_draw()

func display():
	text = arabic.process_text(arabic_input)

func _ready():
	display()
	connect("draw", self, "_on_ALabel_draw")

func _on_ALabel_draw():
	if arabic_input != prev_text:
		display()
		prev_text = arabic_input
