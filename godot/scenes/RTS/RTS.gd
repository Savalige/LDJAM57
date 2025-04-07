extends Node2D

var scn_drone = preload("res://scenes/RTS/scn_drone.tscn")
var scn_hyrophone = preload("res://scenes/RTS/scn_hydrophone.tscn")
var scn_monster = preload("res://scenes/RTS/scn_monster.tscn")

func _ready():
	for i in ScrGlobalRts.drones.size():
		var drone = scn_drone.instantiate()
		self.add_child(drone)
		drone.id = i
	
	for i in ScrGlobalRts.hydrophones.size():
		var hydrophone = scn_hyrophone.instantiate()
		self.add_child(hydrophone)
		hydrophone.id = i
	
	for i in ScrGlobalRts.monsters.size():
		var monster = scn_monster.instantiate()
		self.add_child(monster)
		monster.id = i
	
	ScrGlobalRts.base_box = ScrGlobalRts.BaseBox.HYDROPHONE

func _physics_process(delta):
	ScrGlobalRts.physics_step(delta)

func _input(event):
	if event is InputEventKey and event.keycode == KEY_SPACE and event.is_pressed():
		ScrGlobalRts.emit_attention(get_global_mouse_position(), 500)
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		#ScrGlobalRts.emit_attention(get_global_mouse_position(), 10000)
	#elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		#ScrGlobalRts.emit_attention(get_global_mouse_position(), 1000000)
