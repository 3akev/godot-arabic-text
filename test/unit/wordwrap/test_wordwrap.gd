extends "res://addons/gut/test.gd"


const wordwrap = preload("res://addons/arabic-text/wordwrap/wordwrap.gd")

var font = DynamicFont.new()
var size = Vector2(300, 200)

func before_all():
	font.font_data = preload("res://MarkaziText-Bold.ttf")

func test_wordwrap_basic():
	var input = "تحتل ويكيبيديا العربية المركز الـ15 من حيث أضخم الويكيبيديات حسب عدد المقالات، والمرتبة 10 من ناحية العمق متجاوزةً بذلك نسبة العمق في ويكيبيديا الفرنسية والألمانية والإسبانية وغيرها،[بحاجة لدقة أكثر] وتلقى نسبة 1.2% من حجم زوار ويكيبيديا حول العالم"
	var expected = """تحتل ويكيبيديا العربية المركز الـ15 من حيث أضخم
الويكيبيديات حسب عدد المقالات، والمرتبة 10
من ناحية العمق متجاوزةً بذلك نسبة العمق في ويكيبيديا
الفرنسية والألمانية والإسبانية وغيرها،[بحاجة
لدقة أكثر] وتلقى نسبة 1.2% من حجم زوار ويكيبيديا
حول العالم"""
	var result = wordwrap.wrap_text(input, font, size)
	assert_eq(result, expected)
