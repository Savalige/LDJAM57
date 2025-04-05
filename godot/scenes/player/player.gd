extends CharacterBody3D
class_name Player

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.004

var paused = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var footsteps = [
	load("res://assets/audio/sfx/Footsteps/Metal/sfx_footstep_metal_1.wav"),
	load("res://assets/audio/sfx/Footsteps/Metal/sfx_footstep_metal_2.wav"),
	load("res://assets/audio/sfx/Footsteps/Metal/sfx_footstep_metal_3.wav"),
	load("res://assets/audio/sfx/Footsteps/Metal/sfx_footstep_metal_4.wav"),
	load("res://assets/audio/sfx/Footsteps/Metal/sfx_footstep_metal_5.wav"),
	load("res://assets/audio/sfx/Footsteps/Metal/sfx_footstep_metal_6.wav"),
	load("res://assets/audio/sfx/Footsteps/Metal/sfx_footstep_metal_7.wav"),
	load("res://assets/audio/sfx/Footsteps/Metal/sfx_footstep_metal_8.wav"),
]

@onready var ray = $Camera3D/RayCast
@onready var foot_audio: AudioStreamPlayer = $Footsteps

var rng = RandomNumberGenerator.new()
var step_id = -1

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		$Camera3D.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -deg_to_rad(70), deg_to_rad(70))

func _physics_process(_delta):
	# Add the gravity.
	# if not is_on_floor():
	# 	velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if !paused:
		move_and_slide()
		if not (velocity.x == 0 and velocity.y == 0):
			if not foot_audio.is_playing():
				var temp = rng.randi() % 8
				while temp == step_id:
					temp = rng.randi() % 8
				foot_audio.stream = footsteps[temp]
				foot_audio.pitch_scale = rng.randf_range(0.8, 1.2)
				step_id = temp
				foot_audio.play()
