# area3d.gd
extends Area3D

# Reference to the door
@export var door_path: NodePath = "../cabinetdoor"
var door: Node3D

func _ready():
	# Get reference to the door
	door = get_node(door_path)
	
	# Connect the signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Open the door when player enters the area
	if body.is_in_group("player"):
		door.open_door()

func _on_body_exited(body):
	# Close the door when player exits the area
	if body.is_in_group("player"):
		door.close_door()
