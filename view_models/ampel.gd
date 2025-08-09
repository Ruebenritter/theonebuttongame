extends Control

signal lost
signal won

enum Phase {RED, YELLOW, GREEN}
var current_phase: Phase = Phase.RED
var mouse_over = false
var is_grace_period: bool = true


func _ready():
	# Move mouse to a safe position
	%AmpelAnimation.animation = "red"
	%PhaseTimer.wait_time = 2.0
	%GraceTimer.wait_time = 1.0
	%GraceTimer.one_shot = true
	%GraceTimer.autostart = true

	%PhaseTimer.start()
	current_phase = Phase.RED
	

func _on_phase_timer_timeout() -> void:
	match current_phase:
		Phase.RED:
			if mouse_over:
				print("Mouse over during RED phase, lost!")
				lost.emit()
			current_phase = Phase.YELLOW
			%AmpelAnimation.animation = "yellow"
		Phase.YELLOW:
			if !mouse_over:
				print("Mouse left during YELLOW phase, lost!")
				lost.emit()
			current_phase = Phase.GREEN
			%AmpelAnimation.animation = "green"

func _on_ampel_button_mouse_entered() -> void:
	mouse_over = true
	if current_phase == Phase.RED and not is_grace_period:
		print("Mouse entered during RED phase, lost!")
		lost.emit()


func _on_ampel_button_mouse_exited() -> void:
	mouse_over = false
	if current_phase != Phase.GREEN and not is_grace_period:
		print("Mouse exited during non-GREEN phase, lost!")
		lost.emit()


func _on_ampel_button_pressed() -> void:
	%AmpelAnimation.play(%AmpelAnimation.animation)
	if current_phase != Phase.GREEN:
		print("Button pressed during non-GREEN phase, lost!")
		lost.emit()
	else:
		won.emit()


func _on_grace_timer_timeout() -> void:
	is_grace_period = false
