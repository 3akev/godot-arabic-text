static func I1(ch):
	if (ch['level'] % 2) == 0:
		if ch['bidi_type'] == 'R':
			ch['level'] += 1
		elif ch['bidi_type'] in ['AN', 'EN']:
			ch['level'] += 2

static func I2(ch):
	if (ch['level'] % 2) == 1:
		if ch['bidi_type'] in ['L', 'AN', 'EN']:
			ch['level'] += 1

static func resolve_implicit_levels(data):
	for ch in data['chars']:
		I1(ch)
		I2(ch)
