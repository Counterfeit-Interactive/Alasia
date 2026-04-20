extends MultiplayerSpawner

@export var slime: PackedScene

func _ready() -> void:
	spawn_mob.call_deferred()

func spawn_mob():
	if !multiplayer.is_server(): return
	var new_slime = slime.instantiate()
	new_slime.position.y = 4
	new_slime.position.z = -9
	get_node(spawn_path).call_deferred("add_child", new_slime)
