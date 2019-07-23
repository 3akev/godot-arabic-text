extends Label

var reshaper = load('res://reshaper/arabic_reshaper.gd').new()
var bidi = load("res://bidi/algorithm.gd").new()

func _ready():
	text = bidi.get_display(reshaper.reshape(text))
