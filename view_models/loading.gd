extends Control

# button loads (play load animation). lose if pressed before load animation is done
signal lost
signal won

@onready var button: TextureButton = $"PanelContainer/CenterContainer/LoadingButton"
@onready var anim: AnimatedSprite2D = $"PanelContainer/CenterContainer/LoadingButton/AnimatedSprite2D"

enum button_states {
	LOADING,
	READY,
	UNLOADING,
	IDLE
}
