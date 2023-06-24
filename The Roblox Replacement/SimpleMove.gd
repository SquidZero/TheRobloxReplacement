extends Camera3D


var moveVector = Vector3.ZERO;


@export var sensitivity: float = 2.0;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# accumulators
var rot_x = 0
var rot_y = 0

func _input(event):
	moveVector = Vector3.ZERO;
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion:
		# modify accumulated mouse rotation
		rot_x += event.relative.x / -sensitivity
		rot_y += event.relative.y / -sensitivity
		transform.basis = Basis() # reset rotation
		rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X

	if Input.is_action_pressed("forward"):
		moveVector += Vector3.FORWARD;
		translate_object_local(moveVector)
	if Input.is_action_pressed("backward"):
		moveVector += Vector3.BACK;
		translate_object_local(moveVector)
	if Input.is_action_pressed("left"):
		moveVector += Vector3.LEFT;
		translate_object_local(moveVector)
	if Input.is_action_pressed("right"):
		moveVector += Vector3.RIGHT;
		translate_object_local(moveVector)
