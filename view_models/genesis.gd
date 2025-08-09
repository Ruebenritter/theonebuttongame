extends Control

signal won


@export var anim: AnimatedSprite2D;

func _on_button_pressed() -> void:
	anim.play("default")
	await anim.animation_finished
	anim.play_backwards("default")
	await anim.animation_finished
	won.emit()
