extends "res://addons/gut/test.gd"

const paragraph = preload("res://addons/arabic-text/UBA/algorithm/paragraph.gd")

func _assert_inputs(inputs, expected):
	for input in inputs:
		var data = {"chars": paragraph.preprocess_text(input)}
		var result = paragraph.get_paragraph_level(data)
		assert_eq(result, expected)

func test_return_ltr_if_first_strong_char_ltr():
	_assert_inputs([
		"Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
		"Lorem ipsum dolor sit amet. كلام عربي.",
		"(Lorem ipsum dolor sit amet.) كلام عربي."
	], 0)

func test_return_rtl_if_first_strong_char_rtl():
	_assert_inputs([
		"السلام عليكم ورحمة الله وبركاته",
		"كلام عربي. Lorem ipsum dolor sit amet.",
		"(كلام عربي.) Lorem ipsum dolor sit amet."
	], 1)

func test_return_ltr_if_no_strong_chars():
	_assert_inputs(["...:?\';[]+=-"], 0)
