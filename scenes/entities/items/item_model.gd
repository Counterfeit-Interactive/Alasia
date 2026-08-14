extends RigidBody3D
class_name ItemModel
signal entity_entered(body:Node3D, root:Node3D)


var attached_item:Item
var amount:int = 1

func _on_area_3d_body_entered(body: Node3D) -> void:
	entity_entered.emit(body, self)
