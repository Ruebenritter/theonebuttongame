extends Control

signal won

@export var reaction_window: float = 0.15
@export var wait_before_next: float = 0.5

@onready var btn: TextureButton = %TextureButton
@onready var sprite: AnimatedSprite2D = %LoaderAnim
@onready var oops: AnimatedSprite2D = %Oops

var in_reaction_window := false
var current_pattern := 0 # 0 = restart, 1 = reverse

var _input_locked := false
var _has_won := false

func _ready() -> void:
	_start_pattern()

func _start_pattern() -> void:
	if _has_won: # do not restart after winning
		return
	in_reaction_window = false
	_input_locked = false
	current_pattern = randi() % 2
	if current_pattern == 0:
		sprite.play("load")
	else:
		sprite.play_backwards("load")

func _trigger_win() -> void:
	_input_locked = true
	_has_won = true
	print("You won!")
	# ensure the "correct" anim finishes, then emit
	await sprite.animation_finished
	won.emit()
	# Optionally hard-disable the button so hover/clicks are ignored visually too:
	btn.disabled = true
	btn.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _trigger_loss(reason: String) -> void:
	_input_locked = true
	print(reason)
	# play early label on the button + oops feedback
	# NOTE: you already triggered sprite.play("early") before calling this.
	oops.play("default")
	# wait for oops to finish (it’s the visible fail feedback)
	await oops.animation_finished
	# don’t restart if we somehow already won (paranoia guard)
	if _has_won:
		return
	_start_pattern()

func _on_loader_anim_animation_finished() -> void:
	# Only open the window if we didn’t win/lock already
	if _has_won or _input_locked:
		return

	in_reaction_window = true
	await get_tree().create_timer(reaction_window).timeout
	in_reaction_window = false

	# Missed? Just move on to the next pattern after a short pause
	if _has_won or _input_locked:
		return
	await get_tree().create_timer(wait_before_next).timeout
	_start_pattern()

func _on_texture_button_pressed() -> void:
	# Ignore all input when locked or after winning
	if _input_locked or _has_won:
		return

	if in_reaction_window:
		sprite.play("correct")
		_trigger_win()
	else:
		sprite.play("early")
		_trigger_loss("Pressed too early!")
