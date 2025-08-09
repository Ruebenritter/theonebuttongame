extends ColorRect

@onready var _animation_player: AnimationPlayer = $AnimationPlayer

func play_reveal() -> void:
	_animation_player.play("reveal")

func play_hide() -> void:
	_animation_player.play("hide")