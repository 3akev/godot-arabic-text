# -*- coding: utf-8 -*-

# This work is licensed under the MIT License.
# To view a copy of this license, visit https://opensource.org/licenses/MIT

# Written by Abdullah Diab (mpcabd)
# Email: mpcabd@gmail.com
# Website: http://mpcabd.xyz

# Ported and tweaked from Java to Python, from Better Arabic Reshaper
# [https://github.com/agawish/Better-Arabic-Reshaper/]

# Usage:
# Install python-bidi [https://github.com/MeirKriheli/python-bidi], can be
# installed from pip `pip install python-bidi`.

# import arabic_reshaper
# from bidi.algorithm import get_display
# reshaped_text = arabic_reshaper.reshape('اللغة العربية رائعة')
# bidi_text = get_display(reshaped_text)
# Now you can pass `bidi_text` to any function that handles
# displaying/printing of the text, like writing it to PIL Image or passing it
# to a PDF generating method.

const LIGATURES = preload("res://addons/arabic-text/reshaper/ligatures.gd").LIGATURES

const letters = preload("res://addons/arabic-text/reshaper/letters.gd")
const ISOLATED = letters.ISOLATED
const TATWEEL = letters.TATWEEL
const ZWJ = letters.ZWJ
const LETTERS = letters.LETTERS
const FINAL = letters.FINAL
const INITIAL = letters.INITIAL
const MEDIAL = letters.MEDIAL
const UNSHAPED = letters.UNSHAPED


static func reshape(text):
	var HARAKAT_RE = RegEx.new()

	var _ligatures_re = RegEx.new()
	var _ligature_dict = {}
	
	var ligature = '\u0644\u0627'
	var replacement = ['\uFEFB', '', '', '\uFEFC']
	
	_ligature_dict[ligature] = replacement
	_ligatures_re.compile(ligature)
	
	HARAKAT_RE.compile('[\u0610-\u061a\u064b-\u065f\u0670\u06d6-\u06dc\u06df-\u06e8\u06ea-\u06ed\u08d4-\u08e1\u08d4-\u08ed\u08e3-\u08ff]')

	if not text:
		return ''

	var output = []

	var LETTER = 0
	var FORM = 1
	var NOT_SUPPORTED = -1

	var delete_harakat = false
	var delete_tatweel = false
	var support_zwj = false
	var shift_harakat_position = true

	var positions_harakat = {}

	var isolated_form = ISOLATED

	for letter in text:
		if HARAKAT_RE.search(letter):
			if not delete_harakat:
				var position = len(output) - 1
				if shift_harakat_position:
					position -= 1
				if not (position in positions_harakat):
					positions_harakat[position] = []
				if shift_harakat_position:
					positions_harakat[position].insert(0, letter)
				else:
					positions_harakat[position].append(letter)
		elif letter == TATWEEL and delete_tatweel:
			pass
		elif letter == ZWJ and not support_zwj:
			pass
		elif not (letter in LETTERS):
			output.append([letter, NOT_SUPPORTED])
		elif not output:  # first letter
			output.append([letter, isolated_form])
		else:
			var previous_letter = output[-1]
			if previous_letter[FORM] == NOT_SUPPORTED:
				output.append([letter, isolated_form])
			elif not letters.connects_with_letter_before(letter):
				output.append([letter, isolated_form])
			elif not letters.connects_with_letter_after(
					previous_letter[LETTER]
			):
				output.append([letter, isolated_form])
			elif (previous_letter[FORM] == FINAL and not
					letters.connects_with_letters_before_and_after(
						previous_letter[LETTER]
					)):
				output.append([letter, isolated_form])
			elif previous_letter[FORM] == isolated_form:
				output[-1] = [
					previous_letter[LETTER],
					INITIAL
				]
				output.append([letter, FINAL])
			# Otherwise, we will change the previous letter to connect
			# to the current letter
			else:
				output[-1] = [
					previous_letter[LETTER],
					MEDIAL
				]
				output.append([letter, FINAL])

		# Remove ZWJ if it's the second to last item as it won't be useful
		if support_zwj and len(output) > 1 and output[-2][LETTER] == ZWJ:
			output.remove(len(output) - 2)

	if support_zwj and output and output[-1][LETTER] == ZWJ:
		output.pop_back()

	# Clean text from Harakat to be able to find ligatures
	text = HARAKAT_RE.sub(text, '')

	# Clean text from Tatweel to find ligatures if delete_tatweel
	if delete_tatweel:
		text = text.replace(TATWEEL, '')
	
	# ligatures
	var ligs = _ligatures_re.search_all(text)
	if ligs != []:
		for m in ligs: 
			var forms = _ligature_dict[m.strings[0]]
			var a = m.get_start()
			var b = m.get_end()
			var a_form = output[a][FORM]
			var b_form = output[b - 1][FORM]
			var ligature_form = null
		
			# +-----------+----------+---------+---------+----------+
			# | a   \   b | ISOLATED | INITIAL | MEDIAL  | FINAL    |
			# +-----------+----------+---------+---------+----------+
			# | ISOLATED  | ISOLATED | INITIAL | INITIAL | ISOLATED |
			# | INITIAL   | ISOLATED | INITIAL | INITIAL | ISOLATED |
			# | MEDIAL    | FINAL    | MEDIAL  | MEDIAL  | FINAL    |
			# | FINAL     | FINAL    | MEDIAL  | MEDIAL  | FINAL    |
			# +-----------+----------+---------+---------+----------+
		
			if a_form in [isolated_form, INITIAL]:
				if b_form in [isolated_form, FINAL]:
					ligature_form = ISOLATED
				else:
					ligature_form = INITIAL
			else:
				if b_form in [isolated_form, FINAL]:
					ligature_form = FINAL
				else:
					ligature_form = MEDIAL
			output[a] = [forms[ligature_form], NOT_SUPPORTED]
			for i in range(a+1, b):
				output[i] = ['', NOT_SUPPORTED]

	var result = []
	if not delete_harakat and -1 in positions_harakat:
		#result.extend(positions_harakat[-1])
		result +=positions_harakat[-1]
	for o in output:
		var i = output.find(o)
		if o[LETTER]:
			if o[FORM] == NOT_SUPPORTED or o[FORM] == UNSHAPED:
				result.append(o[LETTER])
			else:
				result.append(LETTERS[o[LETTER]][o[FORM]])

		if not delete_harakat:
			if i in positions_harakat:
				#result.extend(positions_harakat[i])
				result += positions_harakat[i]
	
	var str_result = ''
	for s in result:
		str_result += s
	return str_result
