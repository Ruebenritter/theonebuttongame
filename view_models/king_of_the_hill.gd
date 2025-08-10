extends Control

signal won
signal lost

@onready var _enemy_res: PackedScene = preload("res://views/components/king_of_the_hill_enemy.tscn")

@onready var _timer: Timer = $Timer
@onready var _spawn_timer: Timer = $SpawnTimer

@onready var _button_animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var _button: TextureButton = %Button
@onready var _spawn_node: Node2D = %SpawnNode

@onready var _area: Area2D = %Area2D
@onready var _oops: AnimatedSprite2D = %Oops


var _is_pressable = false
var _pressed = false

func _ready() -> void:
	_timer.timeout.connect(_on_timeout)
	_spawn_timer.timeout.connect(_spawn_enemy)
	_button.pressed.connect(_on_button_pressed)
	_area.area_entered.connect(_on_area_entered)

func _on_area_entered(_area: Area2D) -> void:
	if _pressed:
		return
	_timer.stop()
	_oops.play("default")
	await _oops.animation_finished
	lost.emit()

func _spawn_enemy() -> void:
	var side = randi_range(0, 1)

	var x = ProjectSettings.get("display/window/size/viewport_width")
	var y = ProjectSettings.get("display/window/size/viewport_height")

	var side_sign = -1 if side == 0 else 1

	var pot_position = Vector2(side * x + 64 * side_sign, randi_range(0 - 128, y + 128))
	var enemy = _enemy_res.instantiate()

	_spawn_node.add_child(enemy)
	enemy.position = pot_position
	enemy.target = _area.position

func _on_timeout() -> void:
	_is_pressable = true
	_button_animated_sprite.animation = "green"

func _on_button_pressed() -> void:
	if not _is_pressable:
		return
	_pressed = true
	_button_animated_sprite.play("green")
	await _button_animated_sprite.animation_finished
	won.emit()
