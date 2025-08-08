extends Control

# button loads (play load animation). lose if pressed before load animation is done
signal lost
signal won

@onready var button: TextureButton = $"PanelContainer/CenterContainer/Button"
@onready var anim: AnimatedSprite2D = $"PanelContainer/CenterContainer/Button/AnimatedSprite2D"

var is_loaded: bool = false

func _ready() -> void:
    while true:
        anim.play("default")
        await anim.animation_finished
        is_loaded = true
        await get_tree().create_timer(1).timeout
        print("Button is loaded and ready to be pressed.")
        anim.play_backwards("default")
        await anim.animation_finished
        is_loaded = false


func _on_loading_button_pressed() -> void:
    if is_loaded:
        print("Button pressed after loading.")
        won.emit()
    else:
        print("Button pressed before loading.")
        lost.emit()
