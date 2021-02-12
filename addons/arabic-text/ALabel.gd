tool
extends Label

const arabic = preload("res://addons/arabic-text/arabic.gd")
const wordwrap = preload("res://addons/arabic-text/wordwrap/wordwrap.gd")

var prev_text = ""
# Use this for input rather than `text`
export(String, MULTILINE) var arabic_input = '' setget _set_arabic_input

func _ready():
	display()
	connect("draw", self, "_on_ALabel_draw")
	connect("resized",self,"_on_ALabel_draw")
	
func _set_arabic_input(s):
	arabic_input = s
	_on_ALabel_draw()

func _on_ALabel_draw():
	if arabic_input != prev_text:
		display()
		prev_text = arabic_input

func display():
	var temptext = wrap_text(arabic_input) if autowrap else arabic_input
	text = arabic.process_text(temptext)

func wrap_text(input):
	return wordwrap.wrap_text(input, get_font("font"), get_rect().size)

