extends Node3D

signal pressed

@onready var area: Area3D = $Area3D
@onready var timer: Timer = $Timer
@onready var button: Node3D = $Button
@onready var cylinder: Node3D = $Cylinder

var ray: RayCast3D

func _unhandled_input(event):
	if event.is_action_released("interact") and cylinder.position == button.position:
		if ray != null:
			if ray.is_colliding() and ray.get_collider() == area:
				pressed.emit()
				button.position = button.position + (Vector3.DOWN * 0.025)
				timer.start()


func _on_timer_timeout():
	button.position = button.position + (Vector3.UP * 0.025)
