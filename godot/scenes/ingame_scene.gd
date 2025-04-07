extends Node2D

@onready var fade_overlay = $Player/%FadeOverlay
@onready var pause_overlay = $Player/%PauseOverlay
@onready var player = $Player
@onready var terminals = $Terminals
@onready var items = $Items
@onready var bonk_timer: Timer = $BonkTimer
@onready var bonks = $Bonks
@onready var creak_timer: Timer = $CreakTimer
@onready var creaks = $Creaks
@onready var delivery_area = $DeliveryArea
@onready var delivery_hydrophone = $DeliveryArea/hydrophone
@onready var button = $button
@onready var box: Node3D = $dome/Box
@onready var cabinet = $cabinetv2
@onready var monsters = $Monsters
@onready var hydrophones = $Hydrophones

var rng = RandomNumberGenerator.new()

var done = false

func _ready() -> void:
	fade_overlay.visible = true
	
	var monster_audio = ResourceLoader.load("res://assets/audio/music/hunted underwater song 1.ogg")
	for monster in ScrGlobalRts.monsters:
		var audio = AudioStreamPlayer3D.new()
		audio.position = Vector3(monster.pos.x, 0, monster.pos.y) - Vector3(500, 0, 500)
		audio.stream = monster_audio
		audio.autoplay = true
		monsters.add_child(audio)
	
	for phone in ScrGlobalRts.hydrophones:
		var listener = AudioListener3D.new()
		listener.position = Vector3(phone.pos.x, 0, phone.pos.y) - Vector3(500, 0, 500)
		hydrophones.add_child(listener)
	
	for terminal in terminals.get_children():
		terminal.ray = player.ray
		terminal.player = player
		terminal.done.connect(is_done)
	
	for item in items.get_children():
		item.ray = player.ray
		item.player = player
	
	button.ray = player.ray
	cabinet.ray = player.ray
	cabinet.player = player
	
	if SaveGame.has_save():
		SaveGame.load_game(get_tree())
	
	pause_overlay.game_exited.connect(_save_game)
	button.pressed.connect(send_item)
	ScrGlobalRts.base_box_drop.connect(item_got)
	ScrGlobalRts.base_box_pickup.connect(item_taken)

func is_done():
	done = true

func _input(event) -> void:
	if event.is_action_pressed("pause") and not pause_overlay.visible:
		get_viewport().set_input_as_handled()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
		pause_overlay.grab_button_focus()
		pause_overlay.visible = true
	if event.is_action_released("interact"):
		if player.ray != null:
			if player.ray.is_colliding() and player.ray.get_collider() == $Area3D:
				if done:
					player.win.emit()
			if player.ray.is_colliding() and player.ray.get_collider() == delivery_area and box.visible == false:
				if delivery_hydrophone.visible == false and player.hydrophone.visible == true:
					player.hydrophone.visible = false
					delivery_hydrophone.visible = true
				elif delivery_hydrophone.visible == true and player.hydrophone.visible == false:
					player.hydrophone.visible = true
					delivery_hydrophone.visible = false

func _save_game() -> void:
	SaveGame.save_game(get_tree())


func _physics_process(delta):
	ScrGlobalRts.physics_step(delta)
	for i in len(ScrGlobalRts.monsters):
		if ScrGlobalRts.monsters[i].pos.distance_to(Vector2(500, 500)) < 10:
			player.lost.emit()
		monsters.get_children()[i].position = Vector3(ScrGlobalRts.monsters[i].pos.x, 0, ScrGlobalRts.monsters[i].pos.y) - Vector3(500, 0, 500)
	for i in len(ScrGlobalRts.hydrophones):
		hydrophones.get_children()[i].position = Vector3(ScrGlobalRts.hydrophones[i].pos.x, 0, ScrGlobalRts.hydrophones[i].pos.y) - Vector3(500, 0, 500)

func _on_bonk_timer_timeout():
	bonks.get_children()[rng.randi() % bonks.get_child_count()].play()
	bonk_timer.wait_time = rng.randf_range(10, 60)
	bonk_timer.start()

func send_item():
	if delivery_hydrophone.visible == true and box.visible == false:
		box.visible = true
		ScrGlobalRts.base_box = ScrGlobalRts.BaseBox.HYDROPHONE
	elif box.visible == true:
		box.visible = false
		ScrGlobalRts.base_box = ScrGlobalRts.BaseBox.EMPTY

func item_taken():
	delivery_hydrophone.visible = false
	box.visible = false
	ScrGlobalRts.base_box = ScrGlobalRts.BaseBox.EMPTY

func item_got(type: ScrGlobalRts.BaseBox):
	if  type == ScrGlobalRts.BaseBox.HYDROPHONE:
		box.visible = true
		delivery_hydrophone.visible = true

func _on_creak_timer_timeout():
	creaks.get_children()[rng.randi() % creaks.get_child_count()].play()
	creak_timer.wait_time = rng.randf_range(10, 60)
	creak_timer.start()
