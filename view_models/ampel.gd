extends Control

signal lost
signal won

enum Phase {RED, YELLOW, GREEN}

var current_phase: Phase = Phase.RED
var mouse_over := false
var is_grace_period := true
var grace_time: float = 0.5
var phase_time: float = 2.0

var _has_lost := false
var _has_won := false

func _ready() -> void:
	%AmpelAnimation.animation = "red"
	%PhaseTimer.wait_time = phase_time
	%GraceTimer.wait_time = grace_time
	%GraceTimer.one_shot = true
	%GraceTimer.autostart = true

	%PhaseTimer.start()
	current_phase = Phase.RED
	_refresh_hover_deferred()


func _on_phase_timer_timeout() -> void:
	match current_phase:
		Phase.RED:
			if mouse_over:
				_trigger_loss("Mouse over during RED phase, lost!")
				return
			current_phase = Phase.YELLOW
			%AmpelAnimation.animation = "yellow"

		Phase.YELLOW:
			if not mouse_over:
				_trigger_loss("Mouse not on button during YELLOW phase, lost!")
				return # stop here, don't go to green
			current_phase = Phase.GREEN
			%AmpelAnimation.animation = "green"

func _on_ampel_button_mouse_entered() -> void:
	mouse_over = true
	if current_phase == Phase.RED and not is_grace_period:
		_trigger_loss("Mouse entered during RED phase, lost!")

func _on_ampel_button_mouse_exited() -> void:
	mouse_over = false
	if current_phase != Phase.GREEN and not is_grace_period:
		_trigger_loss("Mouse exited during non-GREEN phase, lost!")

func _on_ampel_button_pressed() -> void:
	%AmpelAnimation.play(%AmpelAnimation.animation)
	if current_phase != Phase.GREEN:
		_trigger_loss("Button pressed during non-GREEN phase, lost!")
	else:
		_trigger_win()

func _on_grace_timer_timeout() -> void:
	is_grace_period = false

# --- Helpers ---
func _trigger_loss(reason: String) -> void:
	if _has_lost or _has_won:
		return
	_has_lost = true
	print(reason)
	%PhaseTimer.stop()
	%Oops.play("default")
	await %Oops.animation_finished
	lost.emit()

func _trigger_win() -> void:
	if _has_lost or _has_won:
		return
	_has_won = true
	%PhaseTimer.stop()
	won.emit()

func _refresh_hover_deferred() -> void:
	await get_tree().process_frame
	_refresh_hover_now()

func _refresh_hover_now() -> void:
	if !is_instance_valid(%AmpelButton):
		return
	var mouse_pos = %AmpelButton.get_local_mouse_position()
	mouse_over = Rect2(Vector2.ZERO, %AmpelButton.size).has_point(mouse_pos)
	print("Mouse over button:", mouse_over)