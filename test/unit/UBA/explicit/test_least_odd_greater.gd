extends "res://addons/gut/test.gd"

const explicit = preload("res://addons/arabic-text/UBA/algorithm/explicit.gd")

func _assert_inputs(data):
	for input in data:
		var expected = data[input]
		var result = explicit._least_odd_greater(input)
		assert_eq(result, expected)

func test_least_odd_greater_returns_least_odd_number_greater_than_x():
	_assert_inputs({
		1: 3, 
		2: 3, 
		3: 5, 
		4: 5,
		5: 7,
		6: 7,
		7: 9,
		200: 201,
		54238: 54239,
		93847: 93849})
