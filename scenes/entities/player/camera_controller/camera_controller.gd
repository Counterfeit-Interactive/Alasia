class_name CameraController extends SpringArm3D

const MIN_X = -1.2
const MAX_X = -0.8
const HORIZONTAL_ACC = 3.0
const VERTICAL_ACC = 1.0
const MOUSE_ACC = 0.002

func _enter_tree() -> void:
	Game.players.local_player_ready.connect(_init_camera)
	Game.camera_controller = self

func get_camera() -> Camera3D:
	return $Camera3D

func _process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	var joy_dir = Input.get_vector("pan_left","pan_right","pan_up","pan_down")
	rotate_from_vector(joy_dir * delta * Vector2(HORIZONTAL_ACC, VERTICAL_ACC))
	
	$Camera3D.current = true

func _input(event: InputEvent) -> void:
	if !is_multiplayer_authority(): return
	if event is InputEventMouseMotion:
		rotate_from_vector(event.relative * MOUSE_ACC)

func rotate_from_vector(v: Vector2):
	if v.length() == 0: return
	rotation.y -= v.x
	rotation.x -= v.y
	rotation.x = clamp(rotation.x, MIN_X, MAX_X)
	
func _init_camera():
	print("init camera")
