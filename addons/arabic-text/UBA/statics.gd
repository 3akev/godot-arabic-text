enum DirectionalOverride { Neutral, RTL, LTR }
enum DirectionalIsolate { True = 1, False = 0 }
const max_depth = 125

static func _get_isolating_run_sequence_struct():
	return {
		chars = [],
		sos_type = null,
		eos_type = null,
		embedding_level = 0,
		embedding_direction = ''
	}

static func _get_char_struct():
	return {
		ch = "",
		bidi_type = null,
		level = null
	}

static func _get_data_struct():
	return {
		level = null,
		chars = [],
		isolating_run_sequences = []
	}
