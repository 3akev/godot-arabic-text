tool
# This file is part of python-bidi
#
# python-bidi is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Copyright (C) 2008-2010 Yaacov Zamir <kzamir_a_walla.co.il>,
# Copyright (C) 2010-2015 Meir kriheli <mkriheli@gmail.com>.

const MIRRORED = preload("res://addons/arabic-text/bidi/mirror.gd").MIRRORED
const unicodedata = preload("res://addons/arabic-text/bidi/unicodedata.gd")
const mappings = preload("res://addons/arabic-text/bidi/mappings.gd")

# Some funcinitions
const PARAGRAPH_LEVELS = {'L': 0, 'AL': 1, 'R': 1}
const EXPLICIT_LEVEL_LIMIT = 62

const X2_X5_KEYS = ['RLE', 'LRE', 'RLO', 'LRO']
const X2_X5_MAPPINGS = {
	'RLE': ['_LEAST_GREATER_ODD', 'N'],
	'LRE': ['_LEAST_GREATER_EVEN', 'N'],
	'RLO': ['_LEAST_GREATER_ODD', 'R'],
	'LRO': ['_LEAST_GREATER_EVEN', 'L'],
}

# Added 'B' so X6 won't execute in that case and X8 will run it's course
const X6_IGNORED = X2_X5_KEYS + ['BN', 'PDF', 'B']
const X9_REMOVED = X2_X5_KEYS + ['BN', 'PDF']


static func _embedding_direction(x):
	return ['L', 'R'][x % 2]

const _IS_UCS2 = false
const _SURROGATE_MIN = 55296  # D800
const _SURROGATE_MAX = 56319  # DBFF

static func get_base_level(text, upper_is_rtl=false):
	var base_level = null

	var prev_surrogate = false
	# P2
	for _ch in text:
		# surrogate in case of ucs2
		if _IS_UCS2 and (_SURROGATE_MIN <= _ch.ord_at(0) <= _SURROGATE_MAX):
			prev_surrogate = _ch
			continue
		elif prev_surrogate:
			_ch = prev_surrogate + _ch
			prev_surrogate = false

		# treat upper as RTL ?
		if upper_is_rtl and _ch.isupper():
			base_level = 1
			break

		var bidi_type = unicodedata.bidirectional(_ch)

		if bidi_type in ['AL', 'R']:
			base_level = 1
			break

		elif bidi_type == 'L':
			base_level = 0
			break

	# P3
	if base_level == null:
		base_level = 0

	return base_level


static func get_embedding_levels(text, storage, upper_is_rtl=false, debug=false):
	var prev_surrogate = false
	var base_level = storage['base_level']

	# preset the storage's chars
	for _ch in text:
		if _IS_UCS2 and (_SURROGATE_MIN <= _ch.ord_at(0) <= _SURROGATE_MAX):
			prev_surrogate = _ch
			continue
		elif prev_surrogate:
			_ch = prev_surrogate + _ch
			prev_surrogate = false
		
		var bidi_type = null
		if upper_is_rtl and _ch.isupper():
			bidi_type = 'R'
		else:
			bidi_type = unicodedata.bidirectional(_ch)

		storage['chars'].append({
			'ch': _ch,
			'level': base_level,
			'type': bidi_type,
			'orig': bidi_type
		})


static func explicit_embed_and_overrides(storage, debug=false):
	var overflow_counter = 0
	var almost_overflow_counter = 0
	var directional_override = 'N'
	var levels = []

	# X1
	var embedding_level = storage['base_level']

	for _ch in storage['chars']:
		var bidi_type = _ch['type']
		
		var x2_x5_mapping = X2_X5_MAPPINGS.get(bidi_type, [null, null])
		var level_func_name = x2_x5_mapping[0]
		var override = x2_x5_mapping[1]
		
		var level_func 
		if level_func_name != null:
			level_func = funcref(mappings, level_func_name)

		if level_func != null:
			# So this is X2 to X5
			# if we've past EXPLICIT_LEVEL_LIMIT, note it and do nothing

			if overflow_counter != 0:
				overflow_counter += 1
				continue

			var new_level = level_func.call_func(embedding_level)
			if new_level < EXPLICIT_LEVEL_LIMIT:
				levels.append([embedding_level, directional_override])
				embedding_level = new_level
				directional_override = override

			elif embedding_level == EXPLICIT_LEVEL_LIMIT - 2:
				# The new level is invalid, but a valid level can still be
				# achieved if this level is 60 and we encounter an RLE or
				# RLO further on.  So record that we 'almost' overflowed.
				almost_overflow_counter += 1

			else:
				overflow_counter += 1
		else:
			# X6
			if not (bidi_type in X6_IGNORED):
				_ch['level'] = embedding_level
				if directional_override != 'N':
					_ch['type'] = directional_override

			# X7
			elif bidi_type == 'PDF':
				if overflow_counter:
					overflow_counter -= 1
				elif almost_overflow_counter and \
						embedding_level != EXPLICIT_LEVEL_LIMIT - 1:
					almost_overflow_counter -= 1
				elif levels:
					var tmp = levels.pop_back()
					embedding_level = tmp[0]
					directional_override = tmp[1]

			# X8
			elif bidi_type == 'B':
				levels.clear()
				overflow_counter = 0
				almost_overflow_counter = 0
				embedding_level = storage['base_level']
				_ch['level'] = storage['base_level']
				directional_override = 'N'

	# Removes the explicit embeds and overrides of types
	# RLE, LRE, RLO, LRO, PDF, and BN. Adjusts extended chars
	# next and prev as well

	# Applies X9. See http://unicode.org/reports/tr9/#X9
	var x = storage['chars'].duplicate()
	storage['chars'] = []
	for _ch in x:
		if not (_ch['type'] in X9_REMOVED):
			storage['chars'].append(_ch)
			

	calc_level_runs(storage)


static func calc_level_run(b_l, b_r):
	return ['L', 'R'][int(max(b_l, b_r)) % 2]


static func calc_level_runs(storage):
	"""Split the storage to run of char types at the same level.

	Applies X10. See http://unicode.org/reports/tr9/#X10
	"""
	# run level depends on the higher of the two levels on either side of
	# the boundary If the higher level is odd, the type is R; otherwise,
	# it is L

	storage['runs'].clear()
	var chars = storage['chars']

	# empty string ?
	if not chars:
		return

	var first_char = chars[0]

	var sor = calc_level_run(storage['base_level'], first_char['level'])
	var eor = null

	var run_start = 0
	var run_length = 0

	var prev_level = first_char['level']
	var prev_type = first_char['type']
	var curr_level = null
	var curr_type = null
	
	for _ch in chars:
		curr_level = _ch['level']
		curr_type = _ch['type']

		if curr_level == prev_level:
			run_length += 1
		else:
			eor = calc_level_run(prev_level, curr_level)
			storage['runs'].append({'sor': sor, 'eor': eor, 'start': run_start,
									'type': prev_type, 'length': run_length})
			sor = eor
			run_start += run_length
			run_length = 1

		prev_level = curr_level
		prev_type = curr_type

	# for the last char/runlevel
	eor = calc_level_run(curr_level, storage['base_level'])
	storage['runs'].append({'sor': sor, 'eor': eor, 'start': run_start,
							'type': curr_type, 'length': run_length})


static func resolve_weak_types(storage, debug=false):
	"""Resolve weak type rules W1 - W3.

	See: http://unicode.org/reports/tr9/#Resolving_Weak_Types

	"""

	for run in storage['runs']:
		var prev_strong = run['sor']
		var prev_type = run['sor']
		var start = run['start']
		var length = run['length']
		
		var chars = []
		for i in range(start, start+length, 1):
			chars.append(storage['chars'][i])
		
		for _ch in chars:
			# W1. Examine each nonspacing mark (NSM) in the level run, and
			# change the type of the NSM to the type of the previous character.
			# If the NSM is at the start of the level run, it will get the type
			# of sor.
			var bidi_type = _ch['type']

			if bidi_type == 'NSM':
				_ch['type'] = prev_type
				bidi_type = prev_type

			# W2. Search backward from each instance of a European number until
			# the first strong type (R, L, AL, or sor) is found. If an AL is
			# found, change the type of the European number to Arabic number.
			if bidi_type == 'EN' and prev_strong == 'AL':
				_ch['type'] = 'AN'

			# update prev_strong if needed
			if bidi_type in ['R', 'L', 'AL']:
				prev_strong = bidi_type

			prev_type = _ch['type']

		# W3. Change all ALs to R
		for _ch in chars:
			if _ch['type'] == 'AL':
				_ch['type'] = 'R'

		# W4. A single European separator between two European numbers changes
		# to a European number. A single common separator between two numbers of
		# the same type changes to that type.
		for idx in range(1, len(chars) - 1):
			var bidi_type = chars[idx]['type']
			prev_type = chars[idx-1]['type']
			var next_type = chars[idx+1]['type']

			if bidi_type == 'ES' and prev_type == next_type and prev_type == 'EN':
				chars[idx]['type'] = 'EN'

			if bidi_type == 'CS' and prev_type == next_type and \
					prev_type in ['AN', 'EN']:
				chars[idx]['type'] = prev_type

		# W5. A sequence of European terminators adjacent to European numbers
		# changes to all European numbers.
		for idx in range(len(chars)):
			if chars[idx]['type'] == 'EN':
				for et_idx in range(idx-1, -1, -1):
					if chars[et_idx]['type'] == 'ET':
						chars[et_idx]['type'] = 'EN'
					else:
						break
				for et_idx in range(idx+1, len(chars)):
					if chars[et_idx]['type'] == 'ET':
						chars[et_idx]['type'] = 'EN'
					else:
						break

		# W6. Otherwise, separators and terminators change to Other Neutral.
		for _ch in chars:
			if _ch['type'] in ['ET', 'ES', 'CS']:
				_ch['type'] = 'ON'

		# W7. Search backward from each instance of a European number until the
		# first strong type (R, L, or sor) is found. If an L is found, then
		# change the type of the European number to L.
		prev_strong = run['sor']
		for _ch in chars:
			if _ch['type'] == 'EN' and prev_strong == 'L':
				_ch['type'] = 'L'

			if _ch['type'] in ['L', 'R']:
				prev_strong = _ch['type']


static func resolve_neutral_types(storage, debug):
	"""Resolving neutral types. Implements N1 and N2

	See: http://unicode.org/reports/tr9/#Resolving_Neutral_Types

	"""

	for run in storage['runs']:
		var start = run['start']
		var length = run['length']
		# use sor and eor
		var chars = [{'type': run['sor']}]
		for i in range(start, start+length, 1):
			chars.append(storage['chars'][i])
		chars.append({'type': run['eor']})
		
		var total_chars = len(chars)

		var seq_start = null
		var prev_bidi_type = null
		for idx in range(total_chars):
			var _ch = chars[idx]
			if _ch['type'] in ['B', 'S', 'WS', 'ON']:
				# N1. A sequence of neutrals takes the direction of the
				# surrounding strong text if the text on both sides has the same
				# direction. European and Arabic numbers act as if they were R
				# in terms of their influence on neutrals. Start-of-level-run
				# (sor) and end-of-level-run (eor) are used at level run
				# boundaries.
				if seq_start == null:
					seq_start = idx
					prev_bidi_type = chars[idx-1]['type']
			else:
				if not (seq_start == null):
					var next_bidi_type = chars[idx]['type']

					if prev_bidi_type in ['AN', 'EN']:
						prev_bidi_type = 'R'

					if next_bidi_type in ['AN', 'EN']:
						next_bidi_type = 'R'

					for seq_idx in range(seq_start, idx):
						if prev_bidi_type == next_bidi_type:
							chars[seq_idx]['type'] = prev_bidi_type
						else:
							# N2. Any remaining neutrals take the embedding
							# direction. The embedding direction for the given
							# neutral character is derived from its embedding
							# level: L if the character is set to an even level,
							# and R if the level is odd.
							chars[seq_idx]['type'] = \
								_embedding_direction(chars[seq_idx]['level'])

					seq_start = null


static func resolve_implicit_levels(storage, debug):
	"""Resolving implicit levels (I1, I2)

	See: http://unicode.org/reports/tr9/#Resolving_Implicit_Levels

	"""
	for run in storage['runs']:
		var start = run['start']
		var length = run['length']
		
		var chars = []
		for i in range(start, start+length, 1):
			chars.append(storage['chars'][i])

		for _ch in chars:
			# only those types are allowed at this stage

			if _embedding_direction(_ch['level']) == 'L':
				# I1. For all characters with an even (left-to-right) embedding
				# direction, those of type R go up one level and those of type
				# AN or EN go up two levels.
				if _ch['type'] == 'R':
					_ch['level'] += 1
				elif _ch['type'] != 'L':
					_ch['level'] += 2
			else:
				# I2. For all characters with an odd (right-to-left) embedding
				# direction, those of type L, EN or AN  go up one level.
				if _ch['type'] != 'R':
					_ch['level'] += 1


static func reverse_contiguous_sequence(storage, line_start, line_end, highest_level,
								lowest_odd_level):
	"""L2. From the highest level found in the text to the lowest odd
	level on each line, including intermediate levels not actually
	present in the text, reverse any contiguous sequence of characters
	that are at that level or higher.

	"""
	var chars = storage['chars']
	for level in range(highest_level, lowest_odd_level-1, -1):
		var _start = null
		var _end = null
		
		var c = null
		
		for run_idx in range(line_start, line_end+1):
			var run_ch = chars[run_idx]

			if run_ch['level'] >= level:
				if _start == null:
					_start = run_idx
					_end = run_idx
				else:
					_end = run_idx
			else:
				if _end != null:
					c = chars.duplicate()
					storage['chars'] = []
					for i in range(0, _start-1, 1):
						storage['chars'].append(c[i])
					for i in range(_end, _start-1, -1):
						storage['chars'].append(c[i])
					for i in range(_end+1, c.size(), 1):
						storage['chars'].append(c[i])
					_start = null
					_end = null

		# anything remaining ?
		if _start != null:
			c = chars.duplicate()
			storage['chars'] = []
			for i in range(0, _start, 1):
				storage['chars'].append(c[i])
			for i in range(_end, _start-1, -1):
				storage['chars'].append(c[i])
			for i in range(_end+1, c.size(), 1):
				storage['chars'].append(c[i])


static func reorder_resolved_levels(storage, debug):
	"""L1 and L2 rules"""

	# Applies L1.

	var should_reset = true
	var chars = storage['chars']
	
	var c = chars.duplicate()
	c.invert()
	for _ch in c:
		# L1. On each line, reset the embedding level of the following
		# characters to the paragraph embedding level:
		if _ch['orig'] in ['B', 'S']:
			# 1. Segment separators,
			# 2. Paragraph separators,
			_ch['level'] = storage['base_level']
			should_reset = true
		elif should_reset and _ch['orig'] in ['BN', 'WS']:
			# 3. Any sequence of whitespace characters preceding a segment
			# separator or paragraph separator
			# 4. Any sequence of white space characters at the end of the
			# line.
			_ch['level'] = storage['base_level']
		else:
			should_reset = false

	var max_len = len(chars)

	# L2 should be per line
	# Calculates highest level and lowest odd level on the fly.

	var line_start = 0
	var line_end = 0
	var highest_level = 0
	var lowest_odd_level = EXPLICIT_LEVEL_LIMIT

	for idx in range(max_len):
		var _ch = chars[idx]

		# calc the levels
		var char_level = _ch['level']
		if char_level > highest_level:
			highest_level = char_level
		
		if char_level % 2 == 1 and char_level < lowest_odd_level:
			lowest_odd_level = char_level

		if _ch['orig'] == 'B' or idx == max_len - 1:
			line_end = idx
			# omit line breaks
			if _ch['orig'] == 'B':
				line_end -= 1

			reverse_contiguous_sequence(storage, line_start, line_end,
										highest_level, lowest_odd_level)

			# reset for next line run
			line_start = idx+1
			highest_level = 0
			lowest_odd_level = EXPLICIT_LEVEL_LIMIT


static func apply_mirroring(storage, debug):
	"""Applies L4: mirroring

	See: http://unicode.org/reports/tr9/#L4

	"""
	# L4. A character is depicted by a mirrored glyph if and only if (a) the
	# resolved directionality of that character is R, and (b) the
	# Bidi_Mirrored property value of that character is true.
	for _ch in storage['chars']:
		var unichar = _ch['ch']
		if unicodedata.mirrored(unichar) and _embedding_direction(_ch['level']) == 'R':
			_ch['ch'] = MIRRORED.get(unichar, unichar)


static func get_empty_storage():
	"""Return an empty storage skeleton, usable for testing"""
	return {
		'base_level': null,
		'base_dir': null,
		'chars': [],
		'runs': [],
	}


static func get_display(unicode_or_str, encoding='utf-8', upper_is_rtl=false,
				base_dir=null, debug=false):
	"""Accepts unicode or string. In case it's a string, `encoding`
	is needed as it works on unicode ones (funcault:"utf-8").

	Set `upper_is_rtl` to true to treat upper case chars as strong 'R'
	for debugging (funcault: false).

	Set `base_dir` to 'L' or 'R' to override the calculated base_level.

	Set `debug` to true to display (using sys.stderr) the steps taken with the
	algorithm.

	Returns the display layout, either as unicode or `encoding` encoded
	string.

	"""
	var text_ls = unicode_or_str.split("\n")
	var processed = PoolStringArray()
	for text in text_ls:
		var storage = get_empty_storage()
		
		var base_level = null
		if base_dir == null:
			base_level = get_base_level(text, upper_is_rtl)
		else:
			base_level = PARAGRAPH_LEVELS[base_dir]
	
		storage['base_level'] = base_level
		storage['base_dir'] = ['L', 'R'][base_level]
	
		get_embedding_levels(text, storage, upper_is_rtl, debug)
		explicit_embed_and_overrides(storage, debug)
		resolve_weak_types(storage, debug)
		resolve_neutral_types(storage, debug)
		resolve_implicit_levels(storage, debug)
		reorder_resolved_levels(storage, debug)
		apply_mirroring(storage, debug)
		
		var display = ''
		var chars = storage['chars']
		for _ch in chars:
			display += _ch['ch']
		processed.append(display)
	return processed.join("\n")
