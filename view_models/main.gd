extends Control


@export var scene_list: Array[PackedScene]
var current_scene_index: int = 0
var current_level: Control

func _ready():
	load_level(current_scene_index)
	
func load_level(index: int):
	if current_level:
		current_level.queue_free()
		
	if index < 0 or index >= scene_list.size():
		print("Level index out of bounds:", index)
		return
	

	current_level = scene_list[index].instantiate()
	add_child.call_deferred((current_level))
	
	if current_level.has_signal("won"):
		current_level.connect("won", Callable(self, "_on_level_won"))
	if current_level.has_signal("lost"):
		current_level.connect("lost", Callable(self, "_on_level_lost"))
	
func _on_level_won():
	current_scene_index += 1
	if current_scene_index < scene_list.size():
		load_level(current_scene_index)
	else:
		print("Game completed!")
		
func _on_level_lost():
	print("Level Lost! Restarting...")
	current_scene_index = 0
	load_level(current_scene_index)
