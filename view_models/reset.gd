extends Control

signal lost

func _on_button_pressed() -> void:
	lost.emit()
