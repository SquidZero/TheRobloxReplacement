extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var rot_x = 0
var rot_y = 0
@export var sensitivity = 2.0
@export var ray: RayCast3D

var damage = 50
@onready var aimcast = $Marker3D/Camera3D/RayCast3D

func _ready():
	name = str(get_multiplayer_authority())


func _physics_process(delta):
	# Add the gravity.
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir = Input.get_vector("left", "right", "forward", "backward")
		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()

		if Input.is_action_just_pressed("shoot"):
			if aimcast.is_colliding():
				var target = aimcast.get_collider()
				if target.is_in_group("Enemies"):
					print("hit enemy")
					target.health -= damage

		rpc("remote_set_position", global_position)
		rpc("remote_set_rotation", global_rotation)

@rpc("unreliable") func remote_set_position(authority_position):
	global_position = authority_position

@rpc("unreliable") func remote_set_rotation(authority_rotation):
	global_rotation = authority_rotation

func _input(event):
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion:
		# modify accumulated mouse rotation
		rot_x += event.relative.x / (-sensitivity*20)
		rot_y += event.relative.y / (-sensitivity*20)
		transform.basis = Basis()
		$Marker3D/Camera3D.transform.basis = Basis() # reset rotation
		rotate_object_local(Vector3(0, 1, 0), rot_x) # first rotate in Y
		$Marker3D/Camera3D.rotate_object_local(Vector3(1, 0, 0), rot_y) # then rotate in X

#func _rotate(object, axis, rot):
#	object.rotate_object_local(axis, rot)
