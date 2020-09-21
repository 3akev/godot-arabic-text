tool
extends Label

const arabic = preload("res://addons/arabic-text/arabic.gd")

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
	if input.empty(): 
		return
	
	var font: Font = get_font("font")
	var height = font.get_height()

	var size = get_rect().size

	var words = input.split(" ",true)
	var line = words[0]
	var i = 1
	var result = ""

	while i < words.size():
		if font.get_wordwrap_string_size(line,size.x).y <= height:
			line += " " + words[i]
		else:
			if result.length() == 0:
				result = line
			else:
				result = result + "\n" + line
			line = words[i]
		i += 1

	if line.length() > 0:
		if result.length() == 0: 
			result  = line
		else:
			result  = result + "\n" + line
	
	return result

