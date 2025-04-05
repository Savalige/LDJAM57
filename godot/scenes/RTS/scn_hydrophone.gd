extends Node2D

@export var id : int = 0

func _physics_process(delta):
	global_position = ScrGlobalRts.hydrophones[id].pos
	$Sprite2D.visible = ((ScrGlobalRts.hydrophones[id].state == ScrGlobalRts.Hydrophone.State.ACTIVE) or (ScrGlobalRts.hydrophones[id].state == ScrGlobalRts.Hydrophone.State.INACTIVE))
