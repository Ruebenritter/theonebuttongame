extends Control

signal won
signal lost

@export var button_speed: float = 300.0
@export var flee_radius := 400.0
@export var mouse_speed_threshold := 250

@onready var scared_btn: Node2D = %ScaredButton
@onready var stamp_anim: AnimatedSprite2D = %StampPressAnim
@onready var btn_anim: AnimatedSprite2D = %ButtonAnimation
@onready var oops_anim: AnimatedSprite2D = %Oops
@onready var col_shape: CollisionShape2D = %CollisionShape

var _prev_mouse := Vector2.ZERO
var _mouse_speed := 0.0
var _last_button_position := Vector2.ZERO
var _last_flee_dir := Vector2.RIGHT
var _idle_delay := 0.0
var stamped := false
var _exiting := false

func _ready() -> void:
	set_process(false)
	if is_instance_valid(scared_btn):
		scared_btn.position = get_viewport().get_visible_rect().size / 4
		_last_button_position = scared_btn.global_position
	_prev_mouse = get_global_mouse_position()

	if is_instance_valid(stamp_anim):
		stamp_anim.play("default")

	set_process(true)

func _exit_tree() -> void:
	_exiting = true
	set_process(false)

func _process(delta: float) -> void:
	if _exiting or !is_inside_tree():
		return
	if !is_instance_valid(scared_btn):
		return

	# mouse speed
	var mpos = get_global_mouse_position()
	var d = mpos - _prev_mouse
	_mouse_speed = d.length() / max(delta, 0.0001)
	_prev_mouse = mpos

	# Enable stamp collision only during frames 3–4
	if is_instance_valid(stamp_anim) and is_instance_valid(col_shape):
		var frame = stamp_anim.frame
		col_shape.disabled = not (frame >= 3 and frame <= 4)

	# Flee if inside radius
	var my_pos = scared_btn.global_position
	var to_mouse = mpos - my_pos
	var dist = to_mouse.length()
	if dist < flee_radius:
		var away = (my_pos - mpos).normalized()
		if away == Vector2.ZERO:
			away = _last_flee_dir
		else:
			_last_flee_dir = away
		scared_btn.position += away * button_speed * delta

	# Animate run vs idle/press WITHOUT await
	if is_instance_valid(btn_anim):
		if _last_button_position != scared_btn.global_position:
			btn_anim.play("run")
			_idle_delay = 0.2
		else:
			if _idle_delay > 0.0:
				_idle_delay -= delta
				if _idle_delay <= 0.0 and !stamped:
					btn_anim.stop()
					btn_anim.animation = "press"

	_last_button_position = scared_btn.global_position

	# lose if button runs outside viewport
	var vp := get_viewport()
	if vp: # guard viewport during teardown
		var view_size = vp.get_visible_rect().size
		var p = scared_btn.position
		if p.x < 0 or p.x > view_size.x or p.y < 0 or p.y > view_size.y:
			if is_instance_valid(oops_anim):
				oops_anim.play("default")
				# await safely: resume only if still alive
				var t = get_tree().create_timer(0.0) # let the frame process animations
				await t.timeout
				if _exiting: return
				if is_instance_valid(oops_anim):
					await oops_anim.animation_finished
					if _exiting: return
			lost.emit()
			set_process(false)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if _exiting: return
	if area.name != "ButtonArea":
		return

	stamped = true
	set_process(false)

	# defer the win sequence to avoid touching freed nodes
	call_deferred("_finish_win")

func _finish_win() -> void:
	if _exiting: return
	if is_instance_valid(btn_anim):
		btn_anim.play("press")
		await btn_anim.animation_finished
		if _exiting: return

	if is_instance_valid(stamp_anim):
		stamp_anim.stop()

	if !_exiting:
		won.emit()
