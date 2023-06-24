extends Node

@export var camera: Camera3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var velocity = Vector3.ZERO
	var isJumping: bool

	if isJumping == true:
		$CharacterBody3D.position.y -= 1

	if Input.is_action_pressed("forward"):
		velocity += Vector3.FORWARD
	if Input.is_action_pressed("backward"):
		velocity += Vector3.BACK
	if Input.is_action_pressed("right"):
		velocity += Vector3.RIGHT
	if Input.is_action_pressed("left"):
		velocity += Vector3.LEFT
	if Input.is_action_pressed("jump"):

		velocity += Vector3.UP
	else:
		isJumping = false

	$CharacterBody3D.translate_object_local(velocity)
