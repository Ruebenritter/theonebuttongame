extends Control

signal won
signal lost

@onready var _background_button: TextureButton = %BackgroundTextureButton
@onready var _button: TextureButton = %Button
@onready var _animated_sprite_sheed: AnimatedSprite2D = %ButtonAnimatedSprite2D
@onready var _switch_button = %SwitchButton
@onready var _switch_animated_sprite_sheet: AnimatedSprite2D = %SwitchAnimatedSprite2D
@onready var _oops: AnimatedSprite2D = %Oops
@onready var _panel: PanelContainer = %PanelContainer

var _button_is_ready: bool = false

func _ready() -> void:
	_background_button.pressed.connect(_on_background_button_pressed)
	_switch_button.pressed.connect(_on_switch_button_pressed)
	_button.mouse_entered.connect(_on_mouse_entered)
	_button.pressed.connect(_on_button_pressed)
	_panel.self_modulate = Color.GREEN

func _on_button_pressed() -> void:
	if _button_is_ready:
		_animated_sprite_sheed.play("green")
		await _animated_sprite_sheed.animation_finished
		won.emit()

func _on_background_button_pressed() -> void:
	if _button_is_ready:
		return

	_panel.get("theme_override_styles/panel").set("bg_color", Color.GRAY)

	_button_is_ready = true
	_animated_sprite_sheed.animation = "green"


func _on_mouse_entered() -> void:
	if _button_is_ready:
		return

	_oops.play("default")
	await _oops.animation_finished
	lost.emit()


func _on_switch_button_pressed() -> void:
	_switch_animated_sprite_sheet.play("default")
	await _switch_animated_sprite_sheet.animation_finished
	_oops.play("default")
	await _oops.animation_finished
	lost.emit()
