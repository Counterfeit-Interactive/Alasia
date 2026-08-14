extends Node

var _dialogue_controller_scene:PackedScene = load("res://dialogues/dialogue_ui.tscn")

#func _ready() -> void:
	#dialogue_controller = _dialogue_controller_scene.instantiate()
	#add_child(dialogue_controller)

func begin_dialogue(dialogue):
	DialogueManager.show_dialogue_balloon(dialogue, "start")
