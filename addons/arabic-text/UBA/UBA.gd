# Unicode Bidirectional Algorithm
# https://unicode.org/reports/tr9/
# as of 2020-07-18
#
# This code is written trying to keep true to the algorithm above,
# and is best read alongside it.
#
# Hopefully, it conforms to UAX9-C1

const statics = preload("res://addons/arabic-text/UBA/statics.gd")

const paragraph = preload("res://addons/arabic-text/UBA/algorithm/paragraph.gd")
const explicit = preload("res://addons/arabic-text/UBA/algorithm/explicit.gd")
const prepare_implicit = preload("res://addons/arabic-text/UBA/algorithm/prepare_implicit.gd")
const resolve_weak = preload("res://addons/arabic-text/UBA/algorithm/resolve_weak.gd")
const resolve_neutral = preload("res://addons/arabic-text/UBA/algorithm/resolve_neutral.gd")
const resolve_implicit = preload("res://addons/arabic-text/UBA/algorithm/resolve_implicit.gd")
const reorder_resolved = preload("res://addons/arabic-text/UBA/algorithm/reorder_resolved.gd")

static func display_paragraph(string: String) -> String:
	var data = statics._get_data_struct()
	
	data['chars'] = paragraph.preprocess_text(string)
	data['level'] = paragraph.get_paragraph_level(data)
	
	explicit.explicit_levels_and_directions(data)
	prepare_implicit.preparations_for_implicit_processing(data)
	resolve_weak.resolve_weak_types(data)
	resolve_neutral.resolve_neutral_and_isolate_formatting_types(data)
	resolve_implicit.resolve_implicit_levels(data)
	
	# according to UAX #9, at this point, we can insert shaping & paragraph wrapping.
	# up to this point, no actual reordering happened. just metadata juggling.
	
	reorder_resolved.reorder_resolved_levels(data)
	
	var result = ''
	for ch in data['chars']:
		result += ch['ch']
	
	return result

static func display(text: String) -> String:
	# P1
	var result = PoolStringArray()
	for paragraph in text.split("\n"):
		result.append(display_paragraph(paragraph))
	return result.join("\n")
