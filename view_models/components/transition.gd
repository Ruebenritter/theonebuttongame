extends ColorRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_reveal() -> void:
	animation_player.speed_scale = 0.5
	animation_player.play("reveal")
	

func play_hide() -> void:
	animation_player.speed_scale = 0.5
	animation_player.play("hide")
