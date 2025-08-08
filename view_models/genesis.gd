extends Control

signal won

func _on_button_pressed() -> void:
	won.emit()
