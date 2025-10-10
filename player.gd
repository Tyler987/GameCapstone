extends RigidBody3D
var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0

#jump
var jump_strength := 10.0
var is_on_floor := false

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	gravity_scale = 0.9
	lock_rotation = true

func _process(delta: float) -> void:
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	apply_central_force(twist_pivot.basis * input *1200.0 * delta)

#jump
	if Input.is_action_just_pressed("jump") and is_on_floor:
		apply_central_impulse(Vector3.UP * jump_strength)

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(
		pitch_pivot.rotation.x,deg_to_rad(-30),deg_to_rad(30))
	twist_input = 0
	pitch_input = 0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity
			pitch_input = - event.relative.y * mouse_sensitivity
			
			
func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position + Vector3.DOWN * 1.1
	)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	is_on_floor = result.size() > 0
