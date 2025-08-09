extends Control

const TROLLEY_SPEED: float = 50

signal won


enum Decision {UP, DOWN}


@onready var _trolley: Node2D = %Trolley
@onready var _button: TextureButton = %Button
@onready var _button_spirte: AnimatedSprite2D = %ButtonAnimatedSprite

@onready var _gate: AnimatedSprite2D = %TrolleyGate

@onready var _setup_path_follow: PathFollow2D = %SetupPathFollow2D
@onready var _up_path_follow: PathFollow2D = %UpPathFollow2D
@onready var _down_path_follow: PathFollow2D = %DownPathFollow2D
@onready var _oops: AnimatedSprite2D = %Oops

var _current_decision: Decision = Decision.UP
var _decided: bool = false
var _finished: bool = false
var _commented: bool = false

func _ready() -> void:
	_button.pressed.connect(_on_button_pressed)


func _process(delta: float) -> void:
	if _decided:
		_process_decided(delta)
	else:
		_process_undecided(delta)

func _process_decided(delta: float) -> void:
	_up_path_follow.progress += delta * TROLLEY_SPEED
	_down_path_follow.progress += delta * TROLLEY_SPEED

	if !_commented and _down_path_follow.progress_ratio >= 0.65:
		_commented = true
		_oops.play()

	if !_finished and _down_path_follow.progress_ratio >= 1.0:
		_finished = true
		won.emit()

func _process_undecided(delta: float) -> void:
	var next = _setup_path_follow.progress + delta * TROLLEY_SPEED
	if next >= _setup_path_follow.get_parent().curve.get_baked_length():
		_decided = true
		match _current_decision:
			Decision.UP:
				_trolley.reparent(_up_path_follow)
			Decision.DOWN:
				_trolley.reparent(_down_path_follow)
	else:
		_setup_path_follow.progress = next


func _on_button_pressed() -> void:
	_switch_decision()
	_button_spirte.play("default")

func _switch_decision() -> void:
	match _current_decision:
		Decision.UP:
			_current_decision = Decision.DOWN
			_gate.play("down")
		Decision.DOWN:
			_current_decision = Decision.UP
			_gate.play("up")
