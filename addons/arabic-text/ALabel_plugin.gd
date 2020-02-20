tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("ALabel", "Label", preload("res://addons/arabic-text/ALabel.gd"), null)

func _exit_tree():
	remove_custom_type("ALabel")
