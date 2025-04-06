extends Node2D

@export var id : int = 0

func _physics_process(delta):
	queue_redraw()
	
	global_position = ScrGlobalRts.monsters[id].pos
	$Pos.rotation = ScrGlobalRts.monsters[id].angle
	
	$Target.visible = (ScrGlobalRts.monsters[id].state != ScrGlobalRts.Monster.State.IDLE)
	$Target.global_position = ScrGlobalRts.monsters[id].target
	
	if ScrGlobalRts.monsters[id].state == ScrGlobalRts.Monster.State.IDLE:
		$Label.text = "Idle"
	elif ScrGlobalRts.monsters[id].state == ScrGlobalRts.Monster.State.ROAMING:
		$Label.text = "Roaming"
	elif ScrGlobalRts.monsters[id].state == ScrGlobalRts.Monster.State.INVESTIGATE:
		$Label.text = "Investigate"
#
#func _input(event):
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		#ScrGlobalRts.monsters[id].target = get_global_mouse_position()
		#ScrGlobalRts.monsters[id].state = ScrGlobalRts.Monster.State.ROAMING

func _draw():
	if ScrGlobalRts.monsters[id] is ScrGlobalRts.Roamer:
		draw_rect(Rect2(ScrGlobalRts.monsters[id].area.position - global_position, ScrGlobalRts.monsters[id].area.size), Color.RED, false, 2)
