extends Control

signal won
signal lost

var needs_to_wait := true
var grace_time: float = 0.5
var is_grace_period := true
var mouse_over := false

var _has_lost := false
var _has_won := false
var _anim_playing := false

func _ready() -> void:
	%Oops.position = %Map.position

	%WaitTimer.wait_time = 2.0
	%WaitTimer.one_shot = true
	
	%GraceTimer.wait_time = grace_time
	%GraceTimer.one_shot = true

	start_round()

func _on_wait_timer_timeout() -> void:
	print("Wait timer finished, you can press the button now.")
	needs_to_wait = false
	if _has_lost or _has_won:
		return
	%WaitAnimation.animation = "press"

func _on_texture_button_pressed() -> void:
	if _has_lost or _has_won or _anim_playing:
		return

	if not needs_to_wait:
		_anim_playing = true
		%WaitAnimation.play("press")
		await %WaitAnimation.animation_finished
		_anim_playing = false
		_trigger_win()
	else:
		_trigger_loss("Pressed too early!")

func _on_grace_timer_timeout() -> void:
	is_grace_period = false
	if mouse_over and needs_to_wait:
		_trigger_loss("Touched the button after grace period ended!")
	else:
		print("Grace period ended, you cannot touch the red button anymore.")

func _on_texture_button_mouse_entered() -> void:
	mouse_over = true
	if not is_grace_period and needs_to_wait:
		_trigger_loss("Mouse entered button too early!")

func _on_texture_button_mouse_exited() -> void:
	mouse_over = false

func start_round() -> void:
	# Reset round state
	needs_to_wait = true
	is_grace_period = true
	_has_lost = false
	_has_won = false
	_anim_playing = false
	mouse_over = false

	%WaitAnimation.animation = "dont"
	%GraceTimer.start()
	%WaitTimer.start()

func _trigger_loss(reason: String) -> void:
	if _has_lost or _has_won:
		return
	_has_lost = true
	print(reason)
	%Oops.play("default")
	await %Oops.animation_finished
	lost.emit()

func _trigger_win() -> void:
	if _has_lost or _has_won:
		return
	_has_won = true
	won.emit()
