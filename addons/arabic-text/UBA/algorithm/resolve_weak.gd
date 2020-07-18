static func W1(data, sequence, ch, char_index):
	if ch['bidi_type'] != "NSM":
		return
	
	if ch == sequence.chars[0]:
		ch['bidi_type'] == sequence.sos_type
	else:
		var prev_char = data['chars'][char_index - 1]
		if prev_char['bidi_type'] in ['PDI', 'LRI', 'RLI', 'FSI']:
			ch['bidi_type'] = "ON"
		else:
			ch ['bidi_type'] = prev_char['bidi_type']

static func W2(ch, last_strong_type):
	if ch['bidi_type'] != 'EN':
		return
	
	if last_strong_type == 'AL':
		ch['bidi_type'] = 'AN'

static func W3(ch):
	if ch['bidi_type'] == 'AL':
		ch['bidi_type'] = 'R'

static func W4(data, ch, char_index):
	if char_index > 0 && char_index < data['chars'].size() - 1:
		if ch['bidi_type'] == 'ES':
			var prev_char = data['chars'][char_index - 1]
			var following_char = data['chars'][char_index + 1]
			if prev_char['bidi_type'] == 'EN' && following_char['bidi_type'] == 'EN':
				ch['bidi_type'] = 'EN'
		
		if ch['bidi_type'] == 'CS':
			var prev_char = data['chars'][char_index - 1]
			var following_char = data['chars'][char_index + 1]
			if prev_char['bidi_type'] in ['EN', 'AN'] && following_char['bidi_type'] in ['EN', 'AN']:
				ch['bidi_type'] = prev_char['bidi_type']

static func W5(data, ch, char_index):
	if ch['bidi_type'] != 'EN':
		return
	
	for i in range(char_index, data['chars'].size() - 1):
		var _ch = data['chars'][i]
		if _ch['bidi_type'] != 'ET':
			break
		_ch['bidi_type'] == 'EN'
	for i in range(char_index, 0, -1):
		var _ch = data['chars'][i]
		if _ch['bidi_type'] != 'ET':
			break
		_ch['bidi_type'] == 'EN'

static func W6(ch):
	if ch['bidi_type'] in ['ET', 'ES', 'CS']:
		ch['bidi_type'] == 'ON'

static func W7(ch, last_strong_type):
	if ch['bidi_type'] == 'EN' && last_strong_type == 'L':
		ch['bidi_type'] = 'L'

static func resolve_weak_types(data):
	for sequence in data['isolating_run_sequences']:
		var last_strong_type = null
		for ch in sequence.chars:
			var char_index = data['chars'].find(ch)
			
			if ch['bidi_type'] in ['AL', 'R', 'L']:
				last_strong_type = ch['bidi_type']
			
			W1(data, sequence, ch, char_index)
			W2(ch, last_strong_type)
			W3(ch)
			W4(data, ch, char_index)
			W5(data, ch, char_index)
			W6(ch)
			W7(ch, last_strong_type)
	
	
