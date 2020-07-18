const statics = preload("res://addons/arabic-text/UBA/statics.gd")

static func compare_levels(x, y):
	return ['L', 'R'][(x if x > y else y) % 2]

static func get_isolating_run_sequences(data):
	var isolating_run_sequences = []
	
	var prev_level = data['chars'].front()['level']
	var start = 0
	var end = 0
	
	var PDI_scopes_counter = 0
	for ch in data['chars']:
		if ch['bidi_type'] in ['FSI', 'LRI', 'RLI']:
			PDI_scopes_counter += 1
		if ch['bidi_type'] == "PDI" && PDI_scopes_counter > 0:
			PDI_scopes_counter -= 1
		
		end = data['chars'].find(ch)
		
		if prev_level != ch['level'] || data['chars'].find(ch) >= data['chars'].size() - 1:
			
			# level changed, we have a level run from $start to $end
			if PDI_scopes_counter > isolating_run_sequences.size() - 1:
				isolating_run_sequences.append(statics._get_isolating_run_sequence_struct())
			
			var sequence = isolating_run_sequences[PDI_scopes_counter]
			
			sequence.embedding_level = prev_level
			sequence.embedding_direction = ['L', 'R'][prev_level % 2]
			sequence.chars += data['chars'].slice(start, end)
			
			start = end
		
		prev_level = ch['level']
	
	
	for sequence in isolating_run_sequences:
		var first_index = data['chars'].find(sequence.chars[0])
		var first_level = data['chars'][first_index].level
		var preceding_level = data['level'] if first_index == 0 else data['chars'][first_index - 1].level
		
		sequence.sos_type = compare_levels(first_level, preceding_level)
		
		var last_index = data['chars'].find(sequence.chars[-1])
		var last_level = data['chars'][last_index].level
		var following_level = data['level'] if last_index == 0 else data['chars'][last_index - 1].level
		
		sequence.eos_type = compare_levels(first_level, preceding_level)
	
	return isolating_run_sequences

static func preparations_for_implicit_processing(data):
	# X9
	for ch in data['chars'].duplicate():
		if ch['bidi_type'] in ['RLE', 'LRE', 'RLO', 'LRO', 'PDF', 'BN']:
			data['chars'].erase(ch)
	
	# X10
	data['isolating_run_sequences'] = get_isolating_run_sequences(data)
