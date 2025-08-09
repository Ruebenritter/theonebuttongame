extends Control

# button loads (play load animation). lose if pressed before load animation is done
signal won


var is_loading: bool = false

func _ready() -> void:
	start_loading()


func _on_loading_button_pressed() -> void:
	if is_loading:
		print("Loading in progress, please wait...")
		%LoadingAnimation.play("press_early")
		await %LoadingAnimation.animation_finished
		start_loading()
	
	%LoadingAnimation.play("press_win")
	await %LoadingAnimation.animation_finished
	won.emit() # Emit the won signal when loading is complete

func start_loading() -> void:
	if is_loading:
		print("Already loading, please wait...")
		return
	
	is_loading = true
	%LoadingAnimation.play("loading")
	await %LoadingAnimation.animation_finished
	is_loading = false
