extends MultiplayerSpawner

@export var slime: PackedScene

func _ready() -> void:
	spawn_mob.call_deferred()

func spawn_mob():
	if !multiplayer.is_server(): return
	var slime = slime.instantiate()
	slime.position.y = 4
	slime.position.z = -9
	get_node(spawn_path).call_deferred("add_child", slime)
