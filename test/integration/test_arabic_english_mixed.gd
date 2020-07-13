extends "res://addons/gut/test.gd"

const arabic = preload('res://addons/arabic-text/arabic.gd')

#func test_mixed_arabic_first():
#	var input = "جيد good"
#	var expected = "good ﺪﻴﺟ"
#	var result = arabic.process_text(input)
#	assert_eq(result, expected)

func test_mixed_english_first():
	var input = "good جيد"
	var expected = "good ﺪﻴﺟ"
	var result = arabic.process_text(input)
	assert_eq(result, expected)

func test_mixed_multiple_paragraphs_english_first():
	var input = """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed pulvinar mi id luctus tempus. Cras nec tortor quis tellus sagittis ultricies. Maecenas sed malesuada ipsum, eget auctor tortor. Morbi eu dolor eu tortor consectetur ullamcorper.
هذا البرنامج هو تطبيق ويب مجاني وحديث مرادف لبرنامج الرسام القديم يحول الحروف العربية إلى حروف ممكن إستخدامها في البرامج الغير معربة كأدوب فوتوشوب وغيرها. مثال عندما تكتب ببرنامج التصميم فوتوشوب في النسخ الغير معربة تلاحظ أن الحروف تكتب مقلوبة. هذا البرنامج يحل هذه المشكلة."""
	var expected = """Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed pulvinar mi id luctus tempus. Cras nec tortor quis tellus sagittis ultricies. Maecenas sed malesuada ipsum, eget auctor tortor. Morbi eu dolor eu tortor consectetur ullamcorper.
.ﺔﻠﻜﺸﻤﻟﺍ ﻩﺬﻫ ﻞﺤﻳ ﺞﻣﺎﻧﺮﺒﻟﺍ ﺍﺬﻫ .ﺔﺑﻮﻠﻘﻣ ﺐﺘﻜﺗ ﻑﻭﺮﺤﻟﺍ ﻥﺃ ﻆﺣﻼﺗ ﺔﺑﺮﻌﻣ ﺮﻴﻐﻟﺍ ﺦﺴﻨﻟﺍ ﻲﻓ ﺏﻮﺷﻮﺗﻮﻓ ﻢﻴﻤﺼﺘﻟﺍ ﺞﻣﺎﻧﺮﺒﺑ ﺐﺘﻜﺗ ﺎﻣﺪﻨﻋ ﻝﺎﺜﻣ .ﺎﻫﺮﻴﻏﻭ ﺏﻮﺷﻮﺗﻮﻓ ﺏﻭﺩﺄﻛ ﺔﺑﺮﻌﻣ ﺮﻴﻐﻟﺍ ﺞﻣﺍﺮﺒﻟﺍ ﻲﻓ ﺎﻬﻣﺍﺪﺨﺘﺳﺇ ﻦﻜﻤﻣ ﻑﻭﺮﺣ ﻰﻟﺇ ﺔﻴﺑﺮﻌﻟﺍ ﻑﻭﺮﺤﻟﺍ ﻝﻮﺤﻳ ﻢﻳﺪﻘﻟﺍ ﻡﺎﺳﺮﻟﺍ ﺞﻣﺎﻧﺮﺒﻟ ﻑﺩﺍﺮﻣ ﺚﻳﺪﺣﻭ ﻲﻧﺎﺠﻣ ﺐﻳﻭ ﻖﻴﺒﻄﺗ ﻮﻫ ﺞﻣﺎﻧﺮﺒﻟﺍ ﺍﺬﻫ"""
	var result = arabic.process_text(input)
	assert_eq(result, expected)
#
func test_mixed_multiple_paragraphs_arabic_first():
	var input = """هذا البرنامج هو تطبيق ويب مجاني وحديث مرادف لبرنامج الرسام القديم يحول الحروف العربية إلى حروف ممكن إستخدامها في البرامج الغير معربة كأدوب فوتوشوب وغيرها. مثال عندما تكتب ببرنامج التصميم فوتوشوب في النسخ الغير معربة تلاحظ أن الحروف تكتب مقلوبة. هذا البرنامج يحل هذه المشكلة.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed pulvinar mi id luctus tempus. Cras nec tortor quis tellus sagittis ultricies. Maecenas sed malesuada ipsum, eget auctor tortor. Morbi eu dolor eu tortor consectetur ullamcorper."""
	var expected = """.ﺔﻠﻜﺸﻤﻟﺍ ﻩﺬﻫ ﻞﺤﻳ ﺞﻣﺎﻧﺮﺒﻟﺍ ﺍﺬﻫ .ﺔﺑﻮﻠﻘﻣ ﺐﺘﻜﺗ ﻑﻭﺮﺤﻟﺍ ﻥﺃ ﻆﺣﻼﺗ ﺔﺑﺮﻌﻣ ﺮﻴﻐﻟﺍ ﺦﺴﻨﻟﺍ ﻲﻓ ﺏﻮﺷﻮﺗﻮﻓ ﻢﻴﻤﺼﺘﻟﺍ ﺞﻣﺎﻧﺮﺒﺑ ﺐﺘﻜﺗ ﺎﻣﺪﻨﻋ ﻝﺎﺜﻣ .ﺎﻫﺮﻴﻏﻭ ﺏﻮﺷﻮﺗﻮﻓ ﺏﻭﺩﺄﻛ ﺔﺑﺮﻌﻣ ﺮﻴﻐﻟﺍ ﺞﻣﺍﺮﺒﻟﺍ ﻲﻓ ﺎﻬﻣﺍﺪﺨﺘﺳﺇ ﻦﻜﻤﻣ ﻑﻭﺮﺣ ﻰﻟﺇ ﺔﻴﺑﺮﻌﻟﺍ ﻑﻭﺮﺤﻟﺍ ﻝﻮﺤﻳ ﻢﻳﺪﻘﻟﺍ ﻡﺎﺳﺮﻟﺍ ﺞﻣﺎﻧﺮﺒﻟ ﻑﺩﺍﺮﻣ ﺚﻳﺪﺣﻭ ﻲﻧﺎﺠﻣ ﺐﻳﻭ ﻖﻴﺒﻄﺗ ﻮﻫ ﺞﻣﺎﻧﺮﺒﻟﺍ ﺍﺬﻫ

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed pulvinar mi id luctus tempus. Cras nec tortor quis tellus sagittis ultricies. Maecenas sed malesuada ipsum, eget auctor tortor. Morbi eu dolor eu tortor consectetur ullamcorper."""
	var result = arabic.process_text(input)
	assert_eq(result, expected)
