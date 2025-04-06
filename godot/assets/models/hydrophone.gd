extends Node3D

@onready var area: Area3D = $Area3D

var player: Player
var ray: RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _unhandled_input(event):
	if event.is_action_released("interact"):
		if ray != null:
			if ray.is_colliding() and ray.get_collider() == area:
				player.hydrophone.visible = true
				queue_free()
