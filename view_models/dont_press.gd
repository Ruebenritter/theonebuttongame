extends Control

var needs_to_wait: bool = true

signal won
signal lost

var grace_time: float = 1.0
var is_grace_period: bool = true
var mouse_over: bool = false

func _ready() -> void:
	%Oops.position = %Map.position

	%WaitTimer.wait_time = 3.14
	%WaitTimer.one_shot = true
	%WaitTimer.autostart = false
	
	%GraceTimer.wait_time = grace_time
	%GraceTimer.one_shot = true
	%GraceTimer.autostart = false

	start_round()
	
	
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
		%Oops.play("default")
		start_round()


func _on_grace_timer_timeout() -> void:
	is_grace_period = false
	if mouse_over:
		print("Touched the button after grace period ended, you lost!")
		%Oops.play("default")
		start_round()

	print("Grace period ended, you cannot touch the red button anymore.")
	print("Mouse is over button: ", mouse_over)


func _on_texture_button_mouse_entered() -> void:
	mouse_over = true
	print("Mouse is over button: ", mouse_over)
	if not is_grace_period and needs_to_wait:
		lost.emit()


func _on_texture_button_mouse_exited() -> void:
	mouse_over = false
	print("Mouse is over button: ", mouse_over)

func start_round() -> void:
	print("Mouse is over button: ", mouse_over)
	%WaitAnimation.animation = "dont"
	%GraceTimer.start()
	%WaitTimer.start()

	# update bools
	needs_to_wait = true
	is_grace_period = true
