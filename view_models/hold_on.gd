extends Control


signal won

@onready var hold_timer: Timer = $"HoldTimer"
var is_holding: bool = false
var time_to_wait: int = 3

func _ready():
	hold_timer.wait_time = time_to_wait
	hold_timer.one_shot = true
	hold_timer.autostart = false
	%HoldButton.text = "WIN"

func _on_hold_button_button_down() -> void:
	%HoldButton.text = "HOLD!"
	is_holding = true
	hold_timer.start() # Replace with function body.


func _on_hold_button_button_up() -> void:
	if hold_timer.time_left > 0:
		print("Released too early!")
		%HoldButton.text = "TOO SOON!"
		hold_timer.stop()
		is_holding = false
		
		await get_tree().create_timer(0.4).timeout
		%HoldButton.text = "WIN"
		
		
func _on_hold_timer_timeout() -> void:
	if is_holding:
		modulate = Color(0, 1, 0)
		%HoldButton.text = "YOU WIN!"
		await get_tree().create_timer(1.0).timeout
		won.emit()
