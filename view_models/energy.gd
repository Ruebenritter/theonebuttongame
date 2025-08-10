extends Control

signal won

var _last_mouse_position: Vector2 = Vector2.ZERO
var _last_move_time: float = 0.0
@export var mouse_speed_threshold: float = 200
@export var max_speed_scale: float = 3
var _battery_charged := false

func _ready() -> void:
    _last_mouse_position = get_global_mouse_position()
    _last_move_time = Time.get_ticks_msec() / 1000.0
    %BatteryAnim.speed_scale = 0
    %BatteryAnim.play(%BatteryAnim.animation)
    %BatteryAnim.connect("animation_finished", Callable(self, "_on_battery_animation_finished"))

func _process(delta: float) -> void:
    if _battery_charged:
        return

    var current_position = get_global_mouse_position()
    var current_time = Time.get_ticks_msec() / 1000.0
    var movement = current_position - _last_mouse_position
    var time_diff = current_time - _last_move_time

    if time_diff > 0:
        var speed = movement.length() / time_diff * 0.1

        # Calculate speed scale relative to threshold
        var new_scale = speed / mouse_speed_threshold
        new_scale = clamp(new_scale, 0.0, max_speed_scale)

        %BatteryAnim.speed_scale = new_scale

    _last_mouse_position = current_position
    _last_move_time = current_time

func _on_battery_animation_finished() -> void:
    if _battery_charged:
        return
    _battery_charged = true
    print("Battery charged!")
    %LightContainer.self_modulate = Color(1, 1, 1, 0)


func _on_button_pressed() -> void:
    if not _battery_charged:
        return

    %Anim.play("default")
    await %Anim.animation_finished
    won.emit()
