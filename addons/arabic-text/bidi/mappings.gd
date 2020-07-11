static func _LEAST_GREATER_ODD(x):
	return (x + 1) | 1


static func _LEAST_GREATER_EVEN(x):
	return (x + 2) & ~1
