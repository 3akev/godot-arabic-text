const statics = preload("res://addons/arabic-text/UBA/statics.gd")
const DirectionalOverride = statics.DirectionalOverride
const DirectionalIsolate = statics.DirectionalIsolate
const max_depth = statics.max_depth

const paragraph = preload("res://addons/arabic-text/UBA/algorithm/paragraph.gd")

static func _get_counters_struct():
	return {
		overflow_isolate = 0,
		overflow_embedding = 0,
		valid_isolate = 0
	}

static func _least_odd_greater(x: int) -> int:
	return x + 1 + (x % 2)

static func _least_even_greater(x: int) -> int:
	return x + 1 + ((x+1) % 2)

static func X1(data):
	var stack = []
	var counters = _get_counters_struct()
	
	stack.append([data['level'], DirectionalOverride.Neutral, DirectionalIsolate.False])
	return [stack, counters]

static func X2(ch, stack, counters):
	if ch['bidi_type'] != "RLE":
		return
	
	var new_level_odd = _least_odd_greater(stack.back()[0])
	if counters.overflow_embedding == 0 && counters.overflow_isolate == 0 && new_level_odd < max_depth:
		stack.append([new_level_odd, DirectionalOverride.Neutral, DirectionalIsolate.False])
	else:
		if counters.overflow_isolate == 0:
			counters.overflow_embedding += 1

static func X3(ch, stack, counters):
	if ch['bidi_type'] != "LRE":
		return
	
	var new_level_even = _least_even_greater(stack.back()[0])
	if counters.overflow_embedding == 0 && counters.overflow_isolate == 0 && new_level_even < max_depth - 1:
		stack.append([new_level_even, DirectionalOverride.Neutral, DirectionalIsolate.False])
	else:
		if counters.overflow_isolate == 0:
			counters.overflow_embedding += 1

static func X4(ch, stack, counters):
	if ch['bidi_type'] != "RLO":
		return
	
	var new_level_odd = _least_odd_greater(stack.back()[0])
	if counters.overflow_embedding == 0 && counters.overflow_isolate == 0 && new_level_odd < max_depth:
		stack.append([new_level_odd, DirectionalOverride.RTL, DirectionalIsolate.False])
	else:
		if counters.overflow_isolate == 0:
			counters.overflow_embedding += 1

static func X5(ch, stack, counters):
	if ch['bidi_type'] != "LRO":
		return
	
	var new_level_even = _least_even_greater(stack.back()[0])
	if counters.overflow_embedding == 0 && counters.overflow_isolate == 0 && new_level_even < max_depth - 1:
		stack.append([new_level_even, DirectionalOverride.LTR, DirectionalIsolate.False])
	else:
		if counters.overflow_isolate == 0:
			counters.overflow_embedding += 1

static func X5a(ch, stack, counters):
	if ch['bidi_type'] != "RLI":
		return
	
	ch['level'] = stack.back()[0]
	var directional_override = stack.back()[1]
	
	if directional_override == DirectionalOverride.LTR:
		ch['bidi_type'] = 'L'
	elif directional_override == DirectionalOverride.RTL:
		ch['bidi_type'] = 'R'
	
	var new_level_odd = _least_odd_greater(stack.back()[0])
	if counters.overflow_embedding == 0 && counters.overflow_isolate == 0 && new_level_odd < max_depth:
		counters.valid_isolate += 1
		stack.append([new_level_odd, DirectionalOverride.Neutral, DirectionalIsolate.True])
	else:
		counters.overflow_isolate += 1

static func X5b(ch, stack, counters):
	if ch['bidi_type'] != "LRI":
		return
	
	ch['level'] = stack.back()[0]
	var directional_override = stack.back()[1]
	
	if directional_override == DirectionalOverride.LTR:
		ch['bidi_type'] = 'L'
	elif directional_override == DirectionalOverride.RTL:
		ch['bidi_type'] = 'R'
	
	var new_level_even = _least_even_greater(stack.back()[0])
	if counters.overflow_embedding == 0 && counters.overflow_isolate == 0 && new_level_even < max_depth:
		counters.valid_isolate += 1
		stack.append([new_level_even, DirectionalOverride.Neutral, DirectionalIsolate.True])
	else:
		counters.overflow_isolate += 1

static func X5c(data, ch, stack, counters):
	if ch['bidi_type'] != "FSI":
		return
	
	var start = data['chars'].find(ch)
	var end = 0
	var PDI_scopes_counter = 0
	
	for i in range(start, data['chars'].size()):
		var x = data['chars'][i]
		if x['bidi_type'] in ['FSI', 'LRI', 'RLI']:
			PDI_scopes_counter += 1
		if x['bidi_type'] == "PDI":
			if PDI_scopes_counter == 0:
				end = i
				break
			else:
				PDI_scopes_counter -= 1
	
	if end == 0:
		end = len(data['chars']) - 1
	
	if paragraph.get_paragraph_level(data['chars'].slice(start, end)) == 1:
		ch['bidi_type'] = "RLI"
		X5a(ch, stack, counters)
	else:
		ch['bidi_type'] = "LRI"
		X5b(ch, stack, counters)

static func X6(ch, stack):
	if ch['bidi_type'] in ["B", "BN", "RLE", "LRE", "RLO", "LRO", "PDF", "RLI", "LRI", "FSI", "PDI"]:
		return
	
	ch['level'] = stack.back()[0]
	if stack.back()[1] == DirectionalOverride.RTL:
		ch.bidi_type = 'R'
	elif stack.back()[1] == DirectionalOverride.LTR:
		ch.bidi_type = 'L'

static func X6a(ch, stack, counters):
	if ch['bidi_type'] != "PDI":
		return
	
	if counters.overflow_isolate > 0:
		counters.overflow_isolate -= 1
	elif counters.valid_isolate > 0:
		counters.overflow_embedding = 0
		while stack.back()[2] == DirectionalIsolate.False:
			stack.pop_back()
		stack.pop_back()
		counters.valid_isolate -= 1
	
	var last_status = stack.back()
	ch['level'] = last_status[0]
	if last_status[1] == DirectionalOverride.LTR:
		ch.bidi_type = 'L'
	elif last_status[1] == DirectionalOverride.RTL:
		ch.bidi_type = 'R'

static func X7(ch, stack, counters):
	if ch['bidi_type'] != "PDF":
		return
	
	if counters.overflow_isolate > 0:
		pass
	elif counters.overflow_embedding > 0:
		counters.overflow_embedding -= 1
	elif stack.back()[2] == DirectionalIsolate.False && len(stack) > 2:
		stack.pop_back()

static func explicit_levels_and_directions(data):
	# Applies X1 - X8
	var tmp = X1(data)
	var stack = tmp[0]
	var counters = tmp[1]
	
	for ch in data['chars']:
		X2(ch, stack, counters)
		X3(ch, stack, counters)
		X4(ch, stack, counters)
		X5(ch, stack, counters)
		X5a(ch, stack, counters)
		X5b(ch, stack, counters)
		X5c(data, ch, stack, counters)
		X6(ch, stack)
		X6a(ch, stack, counters)
		X7(ch, stack, counters)
		
		if ch['bidi_type'] == "B": # X8
			# new paragraph, reset variables
			ch.bidi_type = data['level']
			
			tmp = X1(data)
			stack = tmp[0]
			counters = tmp[1]
			
