extends Node2D

@export var id : int = 0

var hover : bool = false
var selected : bool = false

func _ready():
	$Area2D.mouse_entered.connect(_on_Area2D_mouse_entered)
	$Area2D.mouse_exited.connect(_on_Area2D_mouse_exited)

func _physics_process(delta):
	global_position = ScrGlobalRts.drones[id].pos
	$Sprite2D.rotation = ScrGlobalRts.drones[id].angle
	
	$Polygon2D.visible = (ScrGlobalRts.drones[id].state == ScrGlobalRts.Drone.State.MOVING)
	$Polygon2D.global_position = ScrGlobalRts.drones[id].target

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		selected = hover
		$Sprite2D.self_modulate = Color("#42cafd") if selected else Color("#007dc7")
	elif selected and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		if hover:
			if ScrGlobalRts.drones[id].holding == null:
				ScrGlobalRts.drone_attempt_pickup(id)
			else:
				ScrGlobalRts.drone_attempt_drop(id)
		else:
			ScrGlobalRts.drones[id].set_target(get_global_mouse_position())

func _on_Area2D_mouse_entered():
	hover = true

func _on_Area2D_mouse_exited():
	hover = false
