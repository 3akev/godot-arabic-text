const unicodedata = preload("res://addons/arabic-text/UBA/database/unicodedata.gd")
const bidi_mirroring = preload("res://addons/arabic-text/UBA/database/bidi_mirroring.gd")

static func L1(data):
	var resetable_chars = []
	
	for ch in data['chars']:
		var original_type = unicodedata.bidirectional(ch['ch'])
		
		if original_type in ['WS', 'FSI', 'LRI', 'RLI', 'PDI']:
			resetable_chars.append(ch)
		
		elif original_type in ['B', 'S']:
			ch['level'] = data['level']
			for _ch in resetable_chars:
				_ch['level'] = data['level']
			resetable_chars.clear()
		else:
			resetable_chars.clear()
	
	for _ch in resetable_chars:
		_ch['level'] = data['level']

static func L2(data):
	var highest_level = 0
	var lowest_odd_level = INF
	
	for ch in data['chars']:
		if ch['level'] > highest_level:
			highest_level = ch['level']
		if ch['level'] < lowest_odd_level && (ch['level'] % 2) == 1:
			lowest_odd_level = ch['level']
	
	if lowest_odd_level == INF:
		# no rtl text, do nothing
		return
	
	for i in range(highest_level, lowest_odd_level - 1, -1):
		var sequences = [[]]
		var sequence_index = 0
		
		for ch in data['chars'].duplicate():
			if ch['level'] >= i:
				sequences[sequence_index].append(ch)
			elif sequences[sequence_index].size() > 0:
				sequences.append([])
				sequence_index += 1
				
		
		for sequence_chars in sequences:
			if not sequence_chars.empty():
				var first_char = sequence_chars[0]
				var index = data['chars'].find(first_char)
				var chars = []
				
				for j in range(0, index):
					chars.append(data['chars'][j])
				for j in range(index + sequence_chars.size() - 1, index - 1, -1):
					chars.append(data['chars'][j])
				for j in range(index + sequence_chars.size(), data['chars'].size()):
					chars.append(data['chars'][j])
				
				data['chars'] = chars

static func L3(data):
	var non_spacing_chars = []
	
	for ch in data['chars']:
		var original_type = unicodedata.bidirectional(ch['ch'])
		if original_type == 'NSM':
			non_spacing_chars.append(ch)
		elif original_type == 'R':
			non_spacing_chars.append(ch)
			
			var first_char = non_spacing_chars[0]
			var index = data['chars'].find(first_char)
			var chars = []
			
			for j in range(0, index):
				chars.append(data['chars'][j])
			for j in range(index + non_spacing_chars.size() - 1, index - 1, -1):
				chars.append(data['chars'][j])
			for j in range(index + non_spacing_chars.size(), data['chars'].size()):
				chars.append(data['chars'][j])
			
			for j in range(index, index + non_spacing_chars.size()):
				data['chars'].remove(j)
			
			data['chars'] = chars
			
			non_spacing_chars.clear()
		else:
			non_spacing_chars.clear()

static func L4(data):
	for ch in data['chars']:
		if (ch['level'] % 2) == 1 && ch['ch'] in bidi_mirroring.mirrored:
			ch['ch'] = bidi_mirroring.mirrored[ch['ch']]

static func reorder_resolved_levels(data):
	L1(data)
	L2(data)
	L3(data)
	L4(data)
