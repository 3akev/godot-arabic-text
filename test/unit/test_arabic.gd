extends "res://addons/gut/test.gd"

# the intent behind this is to black-box test this mess, find out what works and what doesn't
# this website is useful for getting the correct output:
# http://www.arabic-keyboard.org/photoshop-arabic/

var reshaper = preload('res://addons/arabic-text/reshaper/arabic_reshaper.gd').new()
var bidi = preload("res://addons/arabic-text/bidi/algorithm.gd").new()

func test_single_word_no_ligatures():
	var input = "مستشفى"
	var expected = "ﻰﻔﺸﺘﺴﻣ"
	var result = bidi.get_display(reshaper.reshape(input))
	assert_eq(result, expected)

func test_single_word_ligatures():
	var input = "سلام"
	var expected = "ﻡﻼﺳ"
	var result = bidi.get_display(reshaper.reshape(input))
	assert_eq(result, expected)

func test_multiple_words_no_ligatures():
	var input = "السلام عليكم ورحمة الله وبركاته"
	var expected = "ﻪﺗﺎﻛﺮﺑﻭ ﻪﻠﻟﺍ ﺔﻤﺣﺭﻭ ﻢﻜﻴﻠﻋ ﻡﻼﺴﻟﺍ"
	var result = bidi.get_display(reshaper.reshape(input))
	assert_eq(result, expected)

func test_multiple_words_with_ligatures():
	var input = "السلام ثم الكلام"
	var expected = "ﻡﻼﻜﻟﺍ ﻢﺛ ﻡﻼﺴﻟﺍ"
	var result = bidi.get_display(reshaper.reshape(input))
	assert_eq(result, expected)

func test_multiline():
	var input = """مرحبا
الجو غائم
والرياح شديدة"""
	var expected = """ﺎﺒﺣﺮﻣ
ﻢﺋﺎﻏ ﻮﺠﻟﺍ
ﺓﺪﻳﺪﺷ ﺡﺎﻳﺮﻟﺍﻭ"""
	var result = bidi.get_display(reshaper.reshape(input))
	assert_eq(result, expected)
