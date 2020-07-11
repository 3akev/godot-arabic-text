extends "res://addons/gut/test.gd"

# ensure it doesn't alter english/other LTR languages

const arabic = preload('res://addons/arabic-text/arabic.gd')

func test_english_single_word():
	var input = "godot"
	var result = arabic.process_text(input)
	assert_eq(result, input)

func test_english_multiple_words():
	var input = "godot is cool"
	var result = arabic.process_text(input)
	assert_eq(result, input)

func test_english_multiple_paragraphs():
	var input = """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed pulvinar mi id luctus tempus. Cras nec tortor quis tellus sagittis ultricies. Maecenas sed malesuada ipsum, eget auctor tortor. Morbi eu dolor eu tortor consectetur ullamcorper. Integer vel eros mollis, pulvinar lectus elementum, placerat nisl.
	In sit amet porta nunc. Duis nisl leo, suscipit at vestibulum et, tempus sed turpis. Nulla sit amet interdum nisi. Donec in bibendum neque, id bibendum lectus. Aliquam nec tincidunt magna. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus.
	Etiam blandit, est in iaculis fermentum, ante purus rutrum tellus, a suscipit justo urna nec tortor.
	Mauris et felis leo. Nam sodales pretium neque eu tincidunt. Morbi eu metus ut nunc suscipit facilisis. Sed tincidunt sollicitudin massa in placerat."""
	var result = arabic.process_text(input)
	assert_eq(result, input)
