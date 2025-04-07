extends Node3D

@onready var area = $Area3D
@onready var door = $cabinetdoor
@onready var items = $Items
var ray: RayCast3D
var player: Player

@export var amount: int = 0
@export var max_items = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(amount):
		items.get_children()[i].visible = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if event.is_action_released("interact"):
		if ray != null:
			if ray.is_colliding() and ray.get_collider() == area:
				if door.current_rotation > door.open_angle - 10:
					if player.hydrophone.visible == true and max_items > amount:
						items.get_children()[amount].visible = true
						player.hydrophone.visible = false
						amount += 1
					elif player.hydrophone.visible == false:
						amount -= 1
						items.get_children()[amount].visible = false
						player.hydrophone.visible = true
