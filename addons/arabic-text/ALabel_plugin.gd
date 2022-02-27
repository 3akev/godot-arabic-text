tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("ALabel", "Label", preload("res://addons/arabic-text/ALabel.gd"), null)
	add_custom_type("AnimatedALabel", "Label", preload("res://addons/arabic-text/ALabelWithAnimation.gd"), null)

func _exit_tree():
	remove_custom_type("ALabel")
	remove_custom_type("AnimatedLabelALabel")
