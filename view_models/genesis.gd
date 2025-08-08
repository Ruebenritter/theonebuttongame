extends Control

signal won

@onready var button: TextureButton = $"PanelContainer/CenterContainer/Button"
@onready var anim: AnimatedSprite2D = $"PanelContainer/CenterContainer/Button/AnimatedSprite2D"

func _on_button_pressed() -> void:
	anim.play("default")
	await anim.animation_finished
	anim.play_backwards("default")
	await anim.animation_finished
	won.emit()
