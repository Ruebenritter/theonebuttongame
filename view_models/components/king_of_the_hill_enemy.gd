class_name KingOfTheHillEnemy extends Node2D

const SPEED: float = 20

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _button: TextureButton = %TextureButton

var target: Vector2 = Vector2.ZERO
var _speed_addition: float
var _stop: bool = false

func _ready() -> void:
	_speed_addition = randfn(0, 10)
	_button.pressed.connect(_on_button_pressed)

func _process(delta: float) -> void:
	if _stop:
		return

	position = position.move_toward(target, delta * (SPEED + _speed_addition))

	if position.direction_to(target).dot(Vector2.RIGHT) > 0:
		_animated_sprite.flip_h = true
	else:
		_animated_sprite.flip_h = false

func _on_button_pressed() -> void:
	_stop = true
	_animated_sprite.play("die")
	await _animated_sprite.animation_finished
	queue_free()