const bidi_brackets = preload("res://addons/arabic-text/UBA/database/bidi_brackets.gd")
const unicodedata = preload("res://addons/arabic-text/UBA/database/unicodedata.gd")

class CustomSorter:
	static func sort_ascending(a, b):
		if a[0] < b[0]:
			return true
		return false

static func identify_bracket_pairs(sequence, data):
	var stack = []
	var pair_indexes = []
	
	for ch in sequence.chars:
		if ch.ch in bidi_brackets.brackets:
			var entry = bidi_brackets.brackets[ch.ch]
			var bracket_type = entry[1]
			var text_position = data['chars'].find(ch)
			
			if bracket_type == 'o':
				if stack.size() <= 63:
					stack.append([entry[0], text_position])
				else:
					break
			
			if bracket_type == 'c':
				var element_index = stack.size() - 1
				while  element_index > 0 and entry[0] != stack[element_index][0] :
					element_index -= 1
				
				var element = stack[element_index]
				if element[0] == entry[0]:
					pair_indexes.append([element[1], text_position])
					stack.pop_back()
	
	pair_indexes.sort_custom(CustomSorter, 'sort_ascending')
	
	return pair_indexes

static func N0(sequence, data):
	var bracket_pairs = identify_bracket_pairs(sequence, data)
	
	for bracket_pair in bracket_pairs:
		var strong_type = null
		for ch in data['chars'].slice(bracket_pair[0], bracket_pair[1]):
			var bidi_type = ch['bidi_type']
			if bidi_type in ['EN', 'AN']:
				bidi_type = 'R'
			
			if bidi_type == sequence.embedding_direction:
				data['chars'][bracket_pair[0]]['bidi_type'] = sequence.embedding_direction
				data['chars'][bracket_pair[1]]['bidi_type'] = sequence.embedding_direction
				strong_type = null
				break
			elif bidi_type in ['L', 'R']:
				strong_type = bidi_type
		
		if strong_type != null:
			var found_preceding_strong_type = false
			for i in range(bracket_pair[0], 0, -1):
				var ch = data['chars'][i]
				
				var bidi_type = ch['bidi_type']
				if bidi_type in ['EN', 'AN']:
					bidi_type = 'R'
				
				if bidi_type == strong_type:
					data['chars'][bracket_pair[0]]['bidi_type'] = strong_type
					data['chars'][bracket_pair[1]]['bidi_type'] = strong_type
					found_preceding_strong_type = true
					break
				
			if not found_preceding_strong_type:
				data['chars'][bracket_pair[0]]['bidi_type'] = sequence.embedding_direction
				data['chars'][bracket_pair[1]]['bidi_type'] = sequence.embedding_direction
		
		for ch in data['chars'].slice(bracket_pair[0] + 1, bracket_pair[1]):
			var original_type = unicodedata.bidirectional(ch['ch'])
			if original_type != "NSM":
				break
			ch['bidi_type'] = data['chars'][bracket_pair[0]]['bidi_type']
				

static func N1(sequence):
	var prev_strong_type = null
	var NI_sequence = []
	
	for ch in sequence.chars:
		if ch['bidi_type'] in ['R', 'EN', 'AN']:
			prev_strong_type = 'R'
		elif ch['bidi_type'] == 'L':
			prev_strong_type = 'L'
		
		if ch['bidi_type'] in ["B", "S", "WS", "ON", "FSI", "LRI", "RLI", "PDI"]:
			NI_sequence.append(ch)
			break
	
	if NI_sequence.size() == 0:
		return
	
	var following_strong_type = null
	for ch in sequence.chars.slice(sequence.chars.find(NI_sequence[0]), sequence.chars.size() - 1):
		if not (ch['bidi_type'] in ["B", "S", "WS", "ON", "FSI", "LRI", "RLI", "PDI"]):
			if ch['bidi_type'] in ['R', 'EN', 'AN']:
				following_strong_type = 'R'
			elif ch['bidi_type'] == 'L':
				following_strong_type = 'L'
			break
		else:
			NI_sequence.append(ch)
	
	if prev_strong_type == following_strong_type:
		for ch in NI_sequence:
			ch['bidi_type'] = prev_strong_type
			
static func N2(sequence):
####################  main code ######################
#	for ch in sequence.chars:
#		if ch['bidi_type'] in ["B", "S", "WS", "ON", "FSI", "LRI", "RLI", "PDI"]:
#			ch['bidi_type'] = sequence.embedding_direction
#############  new code ###########################
	var chars = sequence.chars;
	var i = 0 ; 
	for ch in chars:
		if ch['bidi_type'] in ["B", "S", "WS", "ON", "FSI", "LRI", "RLI", "PDI"]:
#			if i<= chars.size() -2 and ch["bidi_type"] == "WS" and chars[i-1]["bidi_type"] != chars[i+1]["bidi_type"]:
			if i<= chars.size() -2 and ch["bidi_type"] == "WS":
#				ch["bidi_type"] = "L";
				if chars[i-1]["bidi_type"] == "R":
					ch["bidi_type"] = "R";
				else :
					ch["bidi_type"] = chars[i+1]["bidi_type"];
			else:
				ch['bidi_type'] = sequence.embedding_direction
		i += 1;

static func resolve_neutral_and_isolate_formatting_types(data):
	for sequence in data['isolating_run_sequences']:
		N0(sequence, data)
		N1(sequence)
		N2(sequence)
