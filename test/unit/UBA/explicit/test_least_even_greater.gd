extends "res://addons/gut/test.gd"

const explicit = preload("res://addons/arabic-text/UBA/algorithm/explicit.gd")

func _assert_inputs(data):
	for input in data:
		var expected = data[input]
		var result = explicit._least_even_greater(input)
		assert_eq(result, expected)

func test_least_even_greater_returns_least_even_number_greater_than_x():
	_assert_inputs({
		1: 2, 
		2: 4, 
		3: 4, 
		4: 6,
		5: 6,
		6: 8,
		7: 8,
		200: 202,
		54238: 54240,
		93847: 93848})
