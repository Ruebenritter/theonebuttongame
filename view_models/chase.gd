extends Control

signal won
signal lost

@export var button_speed: float = 300.0
@export var flee_radius := 400.0
@export var mouse_speed_threshold := 250

var _prev_mouse := Vector2.ZERO
var _mouse_speed := 0.0
var _last_button_position := Vector2.ZERO
var stamped := false

func _ready() -> void:
	set_process(false)
	%ScaredButton.position = get_viewport().get_visible_rect().size / 4
	_prev_mouse = get_global_mouse_position()
	_last_button_position = %ScaredButton.global_position

	%StampPressAnim.play("default")
	set_process(true)

func _process(delta: float) -> void:
		var mpos = get_global_mouse_position()
		var d = mpos - _prev_mouse
		_mouse_speed = d.length() / max(delta, 0.0001)
		_prev_mouse = mpos

		var my_pos = %ScaredButton.global_position
		var to_mouse = mpos - my_pos
		var dist = to_mouse.length()

		if dist < flee_radius and _mouse_speed > mouse_speed_threshold:
			var away = (-to_mouse).normalized()
			var intensity = 1.0 - clamp(dist / flee_radius, 0.0, 1.0)
			%ScaredButton.position += away * button_speed * intensity * delta
		
		if _last_button_position != %ScaredButton.global_position:
			%ButtonAnimation.play("run")
		else:
			await get_tree().create_timer(0.2).timeout
			if stamped:
				return
			%ButtonAnimation.stop()
			%ButtonAnimation.animation = "press"

		_last_button_position = %ScaredButton.global_position

		# lose if button runs outside viewport
		var view_size = get_viewport().get_visible_rect().size

		if %ScaredButton.position.x < 0 or %ScaredButton.position.x > view_size.x or %ScaredButton.position.y < 0 or %ScaredButton.position.y > view_size.y:
			%Oops.play("default")
			await %Oops.animation_finished
			lost.emit()
			set_process(false)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.name == "ButtonArea":
		stamped = true
		set_process(false)
		await get_tree().process_frame
		# press button
		%ButtonAnimation.play("press")
		await %ButtonAnimation.animation_finished
		%StampPressAnim.stop()
		won.emit()
