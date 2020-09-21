tool
extends Label

const arabic = preload("res://addons/arabic-text/arabic.gd")

var prev_text = ""
var processed_text = ""
var old_autowrap = false
# Use this for input rather than `text`
export(String, MULTILINE) var arabic_input = '' setget _set_arabic_input

func _ready():
	if autowrap:
		process_text()
	display()
	connect("draw", self, "_on_ALabel_draw")
	connect("resized",self,"_on_ALabel_draw")
	
func _set_arabic_input(s):
	arabic_input = s
	if autowrap:
		process_text()
	else:
		processed_text = s
	_on_ALabel_draw()

func display():
	text = arabic.process_text(processed_text)
	old_autowrap = autowrap

func _on_ALabel_draw():
	if arabic_input != prev_text:
		display()
		prev_text = arabic_input

func process_text():
	if arabic_input.empty(): 
		processed_text = ""
		return
	
	var text = arabic_input
	var font: Font = get_font("font")
	var size = get_rect().size
	var height = font.get_height()
	var words = text.split(" ",true)
	var line = words[0]
	var i = 1
	var final = ""

	while i < words.size():
		if font.get_wordwrap_string_size(line,size.x).y <= height:
			line += " " + words[i]
		else:
			if final.length() == 0:
				final = line
			else:
				final = final + "\n" + line
			line = words[i]
		i += 1

	if line.length() > 0:
		if final.length() == 0: 
			final  = line
		else:
			final  = final + "\n" + line
	processed_text = final

