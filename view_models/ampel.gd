extends Control

signal lost
signal won

enum Phase {RED, YELLOW, GREEN}
var current_phase: Phase = Phase.RED
var mouse_over = false

@onready var phase_timer: Timer = $"PhaseTimer"
@onready var button: Button = $"PanelContainer/CenterContainer/AmpelButton"


func _ready():
	button.modulate = Color.RED
	button.text = "STOP"
	phase_timer.wait_time = 2.0
	phase_timer.start()
	current_phase = Phase.RED
	

func _on_phase_timer_timeout() -> void:
	match current_phase:
		Phase.RED:
			if mouse_over:
				lost.emit()
			current_phase = Phase.YELLOW
			button.modulate = Color.YELLOW
			button.text = "READY"
			phase_timer.start()
		Phase.YELLOW:
			if !mouse_over:
				lost.emit()
			current_phase = Phase.GREEN
			button.modulate = Color.GREEN
			button.text = "WIN"

func _on_ampel_button_mouse_entered() -> void:
	mouse_over = true
	if current_phase == Phase.RED:
		lost.emit()


func _on_ampel_button_mouse_exited() -> void:
	mouse_over = false
	if current_phase != Phase.GREEN:
		lost.emit() # Replace with function body.


func _on_ampel_button_pressed() -> void:
	if current_phase != Phase.GREEN:
		lost.emit()
	else:
		won.emit()
