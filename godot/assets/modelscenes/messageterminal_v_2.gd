extends Node3D
@onready var display = $Display
@onready var viewport = $Viewport
@onready var area = $Area
var ray: RayCast3D
var mesh_size = Vector2()
var mouse_entered = false
var mouse_held = false
var mouse_inside = false
var last_mouse_pos_3D = null
var last_mouse_pos_2D = null

func _ready():
	# First, instance the message_terminal.tscn
	var terminal = load("res://scenes/message_terminal.tscn").instantiate()
	viewport.add_child(terminal)
	
	# Set up the material for the display
	var material = StandardMaterial3D.new()
	
	# Set the base color to black
	material.albedo_color = Color(0, 0, 0, 1)  # Black base color
	
	# Set up emission for the text
	material.emission_enabled = true
	material.emission_energy = 1.5  # Increased brightness for better visibility
	material.emission_texture = viewport.get_texture()
	
	# Make sure transparency is handled correctly
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	# Apply the material to the display
	display.material_override = material
	
	# Make sure the viewport has a transparent background
	viewport.transparent_bg = true
	
	# Connect mouse signals
	area.mouse_entered.connect(func(): mouse_entered = true)
	area.mouse_exited.connect(func(): mouse_entered = false)
	
	# Make sure viewport processes input
	viewport.set_process_input(true)
	
	# Now, instance the testing.tscn which will send messages to the terminal
	var testing = load("res://scenes/testing.tscn").instantiate()
	viewport.add_child(testing)
	
	# The testing script will use its @onready var terminal = $MessageTerminal
	# So we need to make sure the message_terminal is named correctly
	terminal.name = "MessageTerminal"

func _unhandled_input(event):
	if ray != null:
		if ray.is_colliding() and ray.get_collider() == area:
			mouse_entered = true
		else:
			mouse_entered = false
	
	var is_mouse_event = false
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		is_mouse_event = true
	
	if mouse_entered and (is_mouse_event or mouse_held) and not event is InputEventKey:
		handle_mouse(event)
	elif not is_mouse_event:
		viewport.push_input(event)

func handle_mouse(event):
	mesh_size = display.mesh.size
	
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		mouse_held = event.pressed
	
	var mouse_pos3D = find_mouse(event.global_position)
	
	mouse_inside = mouse_pos3D != null
	
	if mouse_inside:
		mouse_pos3D = area.global_transform.affine_inverse() * mouse_pos3D
		last_mouse_pos_3D = mouse_pos3D
	else:
		mouse_pos3D = last_mouse_pos_3D
		if mouse_pos3D == null:
			mouse_pos3D = Vector3.ZERO
	
	var mouse_pos2D = Vector2(mouse_pos3D.x, -mouse_pos3D.y)
	
	# Convert from -meshsize/2 to meshsize/2
	mouse_pos2D.x += mesh_size.x / 2
	mouse_pos2D.y += mesh_size.y / 2
	# Convert to 0 to 1
	mouse_pos2D.x = mouse_pos2D.x / mesh_size.x
	mouse_pos2D.y = mouse_pos2D.y / mesh_size.y
	# Convert to viewport range 0 to viewport size
	mouse_pos2D.x = mouse_pos2D.x * viewport.size.x
	mouse_pos2D.y = mouse_pos2D.y * viewport.size.y
	
	event.position = mouse_pos2D
	event.global_position = mouse_pos2D
	
	if event is InputEventMouseMotion:
		if last_mouse_pos_2D == null:
			event.relative = Vector2(0, 0)
		else:
			event.relative = mouse_pos2D - last_mouse_pos_2D
	
	last_mouse_pos_2D = mouse_pos2D
	
	viewport.push_input(event)

func find_mouse(pos:Vector2):
	var camera = get_viewport().get_camera_3d()
	
	var dss = get_world_3d().direct_space_state
	
	var rayparam = PhysicsRayQueryParameters3D.new()
	rayparam.from = camera.project_ray_origin(pos)
	var dis = 5
	rayparam.to = rayparam.from + camera.project_ray_normal(pos) * dis
	rayparam.collide_with_bodies = false
	rayparam.collide_with_areas = true
	
	var result = dss.intersect_ray(rayparam)
	if result.size() > 0:
		return result.position
	else:
		return null
