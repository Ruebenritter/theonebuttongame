extends Control

var needs_to_wait: bool = true

signal won
signal lost

var grace_time: float = 1.0
var is_grace_period: bool = true

func _ready() -> void:
	%WaitTimer.wait_time = randf_range(1.5, 3.14)
	%WaitTimer.one_shot = true
	%WaitTimer.autostart = false
	%WaitAnimation.animation = "dont"

	%GraceTimer.wait_time = grace_time
	%GraceTimer.one_shot = true
	%GraceTimer.autostart = false
	
	%GraceTimer.start()
	%WaitTimer.start()


func _on_wait_timer_timeout() -> void:
	print("Wait timer finished, you can press the button now.")
	needs_to_wait = false
	%WaitAnimation.animation = "press"


func _on_texture_button_pressed() -> void:
	if not needs_to_wait:
		%WaitAnimation.play("press")
		%WaitAnimation.play()
		await %WaitAnimation.animation_finished
		won.emit()
	else:
		lost.emit()


func _on_grace_timer_timeout() -> void:
	is_grace_period = false
	print("Grace period ended, you can now press the button without losing.")


func _on_texture_button_mouse_entered() -> void:
	if not is_grace_period and needs_to_wait:
		lost.emit()