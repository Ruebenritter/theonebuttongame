extends Control


signal won

@onready var hold_timer: Timer = $"HoldTimer"
@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D

var is_holding: bool = false
var time_to_wait: float = randf_range(1, 2)
var has_won: bool = false

func _ready():
	hold_timer.wait_time = time_to_wait
	hold_timer.one_shot = true
	hold_timer.autostart = false
	animated_sprite.animation = "hold"

func _on_hold_button_button_down() -> void:
	animated_sprite.play("hold")
	is_holding = true
	hold_timer.start() # Replace with function body.


func _on_hold_button_button_up() -> void:
	if has_won:
		animated_sprite.play("win")
		await animated_sprite.animation_finished
		won.emit()

	if hold_timer.time_left > 0:
		print("Released too early!")
		%Oops.play("default")
		animated_sprite.play_backwards("hold")
		hold_timer.stop()
		is_holding = false
		
		await get_tree().create_timer(0.4).timeout
		if not is_holding: return
		print("Won")
		
func _on_hold_timer_timeout() -> void:
	if is_holding:
		has_won = true
		animated_sprite.animation = "win"
		await get_tree().create_timer(3.0).timeout
		won.emit()
