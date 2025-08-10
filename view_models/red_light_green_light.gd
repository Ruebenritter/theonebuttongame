extends Control

signal won
signal lost

@export var prestart_time_min := 2.0
@export var prestart_time_max := 3.0
@export var green_time_min := 1.2
@export var green_time_max := 2.0
@export var red_time_min := 1.0
@export var red_time_max := 2.0
@export var grace_after_switch := 0.25 # seconds of human reaction time

enum Phase {WHITE, GREEN, RED}
var _phase: Phase = Phase.WHITE

var _prev_mouse := Vector2.ZERO
var _has_started := false
var _has_lost := false
var _has_won := false
var _in_grace := false

func _ready() -> void:
	_prev_mouse = get_global_mouse_position()
	_set_light(Phase.WHITE, false)
	%ButtonAnim.animation = "default"
	%ReadyTimer.wait_time = randf_range(prestart_time_min, prestart_time_max)
	%ReadyTimer.one_shot = true
	%PhaseTimer.one_shot = true
	%GraceTimer.one_shot = true
	%ReadyTimer.start()
	set_process(true)
	$StartHint.visible = true

func _process(_delta: float) -> void:
	if _has_lost or _has_won:
		return

	var mpos = get_global_mouse_position()
	var moved = (mpos - _prev_mouse).length() > 0.5
	_prev_mouse = mpos

	if not _has_started:
		return

	# Moving during RED loses, except during grace or inside the start area.
	if _phase == Phase.RED and moved and not _in_grace and not _is_in_start_area(mpos):
		_trigger_loss("Moved during RED.")

func _is_in_start_area(pos: Vector2) -> bool:
	return %StartPanel.get_global_rect().has_point(pos)

func _on_ready_timer_timeout() -> void:
	if not _is_in_start_area(get_global_mouse_position()):
		_trigger_loss("Not in start area when the game starts.")
		return
	_has_started = true
	$StartHint.visible = false
	%ButtonAnim.animation = "press"
	_next_green()

func _on_phase_timer_timeout() -> void:
	if _phase == Phase.GREEN:
		_next_red()
	elif _phase == Phase.RED:
		_next_green()

func _on_grace_timer_timeout() -> void:
	_in_grace = false

func _next_green() -> void:
	_set_light(Phase.GREEN, true)
	%PhaseTimer.wait_time = randf_range(green_time_min, green_time_max)
	%PhaseTimer.start()

func _next_red() -> void:
	_set_light(Phase.RED, true)
	%PhaseTimer.wait_time = randf_range(red_time_min, red_time_max)
	%PhaseTimer.start()

# set light and optionally start a grace window after switch
func _set_light(p: Phase, start_grace: bool) -> void:
	_phase = p
	match p:
		Phase.WHITE: %Light.frame = 0
		Phase.GREEN: %Light.frame = 1
		Phase.RED: %Light.frame = 2

	if start_grace and grace_after_switch > 0.0:
		_in_grace = true
		%GraceTimer.wait_time = grace_after_switch
		%GraceTimer.start()
	else:
		_in_grace = false

func _on_win_button_pressed() -> void:
	if _has_lost or _has_won or %ReadyTimer.time_left > 0.0:
		return
	%ButtonAnim.play("press")
	await %ButtonAnim.animation_finished
	_trigger_win()

# --- Results ---
func _trigger_loss(reason: String) -> void:
	if _has_lost or _has_won:
		return
	_has_lost = true
	%PhaseTimer.stop()
	%ReadyTimer.stop()
	%GraceTimer.stop()
	%ButtonAnim.play("die")
	print(reason)
	%Oops.play("default")
	await %Oops.animation_finished
	lost.emit()

func _trigger_win() -> void:
	if _has_lost or _has_won:
		return
	_has_won = true
	%PhaseTimer.stop()
	%ReadyTimer.stop()
	%GraceTimer.stop()
	won.emit()
