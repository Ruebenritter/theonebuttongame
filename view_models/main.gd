extends Control


@export var scene_list: Array[PackedScene]
const USE_CAPTURE := false
var current_scene_index: int = 0
var current_level: Control
var _pending_web_hide := false

# mouse friction
var sensitivity: float = 1.0
var smooth_factor: float = 0.15 # lower = smoother, higher = snappier
var smoothed_delta: Vector2 = Vector2.ZERO

func _ready():
	if OS.has_feature("web"):
		# Browsers require a user gesture first
		_pending_web_hide = true
		set_process_unhandled_input(true)
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# (optional) show "Click to start" overlay here
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	load_level(current_scene_index)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		smoothed_delta += event.relative * sensitivity
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_echo():
				return
			
			if event.pressed:
				%Cursor.stop()
				%Cursor.play("click")
	
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			current_scene_index += 1
			load_level(current_scene_index)
			
			
func _process(delta: float) -> void:
	%Cursor.position = get_local_mouse_position()

func _unhandled_input(event: InputEvent) -> void:
	if _pending_web_hide and ((event is InputEventMouseButton and event.is_pressed())):
		if USE_CAPTURE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN and not OS.has_feature("web"):
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT and not OS.has_feature("web"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
func load_level(index: int):
	%Transition.play_hide()
	await %Transition.animation_player.animation_finished

	if current_level:
		%LevelContainer.remove_child(current_level)
		current_level.queue_free()
		
	if index < 0 or index >= scene_list.size():
		print("Level index out of bounds:", index)
		return
	

	current_level = scene_list[index].instantiate()
	%LevelContainer.add_child.call_deferred((current_level))

	%Transition.play_reveal()
	#await %Transition.animation_player.animation_finished
	
	if current_level.has_signal("won"):
		current_level.connect("won", Callable(self, "_on_level_won"))
	if current_level.has_signal("lost"):
		current_level.connect("lost", Callable(self, "_on_level_lost"))
	if current_level.has_signal("reset"):
		current_level.connect("reset", Callable(self, "_on_level_reset"))

func _on_level_won():
	current_scene_index += 1
	if current_scene_index < scene_list.size():
		load_level(current_scene_index)
	else:
		print("Game completed!")
		
func _on_level_lost():
	print("Level Lost! Restarting...")
	load_level(current_scene_index)

func _on_level_reset():
	print("Resetting game...")
	current_scene_index = 0
	load_level(current_scene_index)
