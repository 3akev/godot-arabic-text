var reshaper = preload('res://addons/arabic-text/reshaper/arabic_reshaper.gd').new()
var bidi = preload("res://addons/arabic-text/bidi/algorithm.gd").new()

func process_text(text):
    return bidi.get_display(reshaper.reshape(text))
