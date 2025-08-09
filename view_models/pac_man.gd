extends Control

signal won
signal request_cursor

@export var fodder_cursor: PackedScene


var fed_pac_man: bool = false

func _ready() -> void:
	request_cursor.emit(fodder_cursor.instantiate() as AnimatedSprite2D)

func _on_texture_button_mouse_entered() -> void:
	if fed_pac_man:
		return
	# pac man eats cursor
	%PacAnim.play("default")
	request_cursor.emit()
	await %PacAnim.animation_finished
	fed_pac_man = true


func _on_texture_button_pressed() -> void:
	if fed_pac_man:
		fed_pac_man = false
		%PacAnim.play("press")
		await %PacAnim.animation_finished
		won.emit()
