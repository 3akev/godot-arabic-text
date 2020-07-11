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
	var input = """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed pulvinar mi id luctus tempus. Cras nec tortor quis tellus sagittis ultricies. Maecenas sed malesuada ipsum, eget auctor tortor. Morbi eu dolor eu tortor consectetur ullamcorper. Integer vel eros mollis, pulvinar lectus elementum, placerat nisl. In sit amet porta nunc. Duis nisl leo, suscipit at vestibulum et, tempus sed turpis. Nulla sit amet interdum nisi. Donec in bibendum neque, id bibendum lectus. Aliquam nec tincidunt magna. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam blandit, est in iaculis fermentum, ante purus rutrum tellus, a suscipit justo urna nec tortor. Mauris et felis leo. Nam sodales pretium neque eu tincidunt. Morbi eu metus ut nunc suscipit facilisis. Sed tincidunt sollicitudin massa in placerat.

Sed a nibh quis velit convallis dapibus id vel sem. Vestibulum non leo dignissim ipsum porta vulputate. Curabitur blandit sagittis ipsum vel accumsan. Cras quis sodales urna. Sed hendrerit lectus felis, non consequat leo dictum non. Maecenas sed massa lacinia, placerat tortor non, cursus lacus. Suspendisse potenti. Nullam imperdiet venenatis est, eu dignissim quam aliquam quis. Etiam sodales euismod congue. Phasellus non dolor in turpis porttitor dictum. Nam in imperdiet justo, non volutpat tellus. Suspendisse volutpat rhoncus scelerisque. Integer sit amet tincidunt orci. Mauris iaculis ultricies suscipit. Sed et consectetur enim.

Phasellus gravida tempor dapibus. Proin egestas, eros non dapibus porta, diam odio blandit orci, sed ultrices neque tellus ac dui. Vestibulum et tristique quam. In hac habitasse platea dictumst. Nam venenatis placerat molestie. Maecenas pulvinar quam nulla, commodo bibendum ipsum volutpat vel. Fusce at dui sit amet lacus rutrum imperdiet. Quisque ornare risus ante, non bibendum sem blandit id. Quisque blandit mi laoreet ligula consectetur, eu eleifend felis convallis. Mauris in purus rutrum velit varius molestie id vitae nisi. Sed sed nulla ut odio feugiat dictum at eu dolor. Duis nec iaculis risus. """
	var result = arabic.process_text(input)
	assert_eq(result, input)
