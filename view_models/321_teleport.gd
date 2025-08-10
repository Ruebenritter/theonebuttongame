extends Control

signal won

@onready var _3_button: TextureButton = %"3Button"
@onready var _2_button: TextureButton = %"2Button"
@onready var _1_button: TextureButton = %"1Button"
@onready var _win_button: TextureButton = %"WinButton"

func _ready() -> void:
	_2_button.visible = false
	_1_button.visible = false
	_win_button.visible = false

	_3_button.pressed.connect(_on_button_pressed.bind(_3_button, _2_button))
	_2_button.pressed.connect(_on_button_pressed.bind(_2_button, _1_button))
	_1_button.pressed.connect(_on_button_pressed.bind(_1_button, _win_button))
	_win_button.pressed.connect(_on_win_button_pressed)

func _on_win_button_pressed() -> void:
	var animated_sprite: AnimatedSprite2D = _win_button.get_node("AnimatedSprite2D")

	animated_sprite.play("default")
	await animated_sprite.animation_finished

	won.emit()

func _on_button_pressed(current: TextureButton, next: TextureButton) -> void:
	var animated_sprite: AnimatedSprite2D = current.get_node("AnimatedSprite2D")

	animated_sprite.play("default")
	await animated_sprite.animation_finished
	current.visible = false
	next.visible = true
