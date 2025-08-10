extends Control

signal won

@export var sensitivity := 0.015 # radians per pixel of mouse X
@export var damping := 6.0 # angular damping
@export var min_slow := 0.08 # 0..1 slowdown near center
@export var upright_tolerance_deg := 6.0
@export var rotating_threshold := 0.08 # rad/s to consider "rotating"

@onready var origin: Node2D = %ButtonOrigin
@onready var btn: TextureButton = %RotatingButton
@onready var sprite: AnimatedSprite2D = %RotationAnim
@onready var slow_area: Area2D = %SlowDownArea
@onready var slow_shape: CollisionShape2D = %SlowDownArea/CollisionShape2D

var _ang_vel := 0.0
var _locked := false
var _won := false
var _feedback_playing := false # true while a press animation is playing

func _ready() -> void:
	btn.pressed.connect(_on_btn_pressed)
	if sprite.animation_finished.is_connected(_on_sprite_finished) == false:
		sprite.animation_finished.connect(_on_sprite_finished)

func _input(event: InputEvent) -> void:
	if _locked: return
	if event is InputEventMouseMotion:
		_ang_vel += event.relative.x * sensitivity

func _process(delta: float) -> void:
	# Slowdown with proximity
	var radius := _get_slow_radius()
	var d := origin.global_position.distance_to(get_global_mouse_position())
	var slow := 1.0
	if d < radius:
		slow = clamp(d / radius, min_slow, 1.0)


	# Rotation & damping
	origin.rotation += _ang_vel * delta * slow
	_ang_vel = move_toward(_ang_vel, 0.0, damping * delta)

	# Visual state (don’t override if a press animation is playing)
	if _feedback_playing or _won:
		return

	var upright := _is_upright()
	var rotating := absf(_ang_vel) >= rotating_threshold

	if upright:
		if sprite.animation != "active":
			sprite.stop()
			sprite.animation = "active" # first frame only
	else:
		if rotating and sprite.sprite_frames.has_animation("rotating"):
			if sprite.animation != "rotating" or !sprite.is_playing():
				sprite.play("rotating")
		else:
			if sprite.animation != "disabled":
				sprite.stop()
				sprite.animation = "disabled" # first frame only

func _on_btn_pressed() -> void:
	if _locked: return

	if _is_upright() and sprite.animation == "active":
		_locked = true
		_won = true
		if sprite.sprite_frames.has_animation("active"):
			_feedback_playing = true
			sprite.play("active")
			await sprite.animation_finished
		won.emit()
		btn.disabled = true
		btn.mouse_filter = Control.MOUSE_FILTER_IGNORE
	else:
		%Oops.play("default")
		# Wrong orientation: play disabled once, then resume idle logic
		if sprite.sprite_frames.has_animation("disabled"):
			_feedback_playing = true
			sprite.play("disabled")
			# no await here; _on_sprite_finished will clear the flag

func _on_sprite_finished() -> void:
	if _won:
		return
	_feedback_playing = false
	# After feedback, _process will restore idle/rotating visuals next frame.

func _is_upright() -> bool:
	var a := wrapf(origin.rotation, -PI, PI)
	return absf(a) <= deg_to_rad(upright_tolerance_deg)

func _get_slow_radius() -> float:
	if !is_instance_valid(slow_shape) or slow_shape.shape == null:
		return 128.0
	if slow_shape.shape is CircleShape2D:
		return (slow_shape.shape as CircleShape2D).radius * slow_shape.global_scale.x
	return 128.0
