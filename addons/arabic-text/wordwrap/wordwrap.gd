static func wrap_text(input: String, font: Font, size: Vector2):
	if input.empty(): 
		return

	var height = font.get_height()

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
