extends Node

onready var label = get_parent()
var chars = 0
var current_chars = 0
var text = ""

func _ready():
	get_parent().get_node("Timer").wait_time = label.typing_speed
	text = label.arabic_input
	chars = text.length()
	current_chars = chars - 1
	label.arabic_input = " "
	pass

func _on_Timer_timeout():
	if label.running:
		var output = str_to_array(text)
		for i in current_chars:
			output.remove(output.size() - 1)
		current_chars = clamp(current_chars - 1,0,chars)
		output = array_to_str(output)
		label.arabic_input = output
	pass # Replace with function body.

func array_to_str(array : Array):
	var string = ""
	for i in array:
		string += str(i)
	return string

func str_to_array(string: String):
	var array = []
	for i in string:
		array.append(i)
	return array
