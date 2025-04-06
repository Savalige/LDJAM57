extends Node3D

@onready var area: Area3D = $Area3D
@onready var audio: AudioStreamPlayer3D = $AudioStreamPlayer3D

var player: Player
var ray: RayCast3D


func _unhandled_input(event):
	if event.is_action_released("interact"):
		if ray != null:
			if ray.is_colliding() and ray.get_collider() == area:
				audio.play()
				player.hydrophone.visible = true
				queue_free()
