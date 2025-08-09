class_name MouseCanvasLayer extends CanvasLayer

@onready var cursor_sprite: AnimatedSprite2D = %Cursor

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _process(_delta: float) -> void:
	cursor_sprite.position = get_window().get_mouse_position()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index != MouseButton.MOUSE_BUTTON_LEFT:
			return

		if event.is_echo():
			return

		print("Mouse pressed with device id " + str(event.device) + " with position " + str(event.position))

		if event.pressed:
			cursor_sprite.stop()
			cursor_sprite.play("click")
