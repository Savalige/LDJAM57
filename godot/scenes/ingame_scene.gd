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

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	fade_overlay.visible = true
	
	for terminal in terminals.get_children():
		terminal.ray = player.ray
		terminal.player = player
	
	for item in items.get_children():
		item.ray = player.ray
		item.player = player
	
	button.ray = player.ray
	
	if SaveGame.has_save():
		SaveGame.load_game(get_tree())
	
	pause_overlay.game_exited.connect(_save_game)
	button.pressed.connect(send_item)

func _input(event) -> void:
	if event.is_action_pressed("pause") and not pause_overlay.visible:
		get_viewport().set_input_as_handled()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
		pause_overlay.grab_button_focus()
		pause_overlay.visible = true
	if event.is_action_released("interact") and delivery_hydrophone.visible == false:
		if player.ray != null:
			if player.ray.is_colliding() and player.ray.get_collider() == delivery_area:
				player.hydrophone.visible = false
				delivery_hydrophone.visible = true

func _save_game() -> void:
	SaveGame.save_game(get_tree())


func _physics_process(delta):
	ScrGlobalRts.physics_step(delta)

func _on_bonk_timer_timeout():
	bonks.get_children()[rng.randi() % bonks.get_child_count()].play()
	bonk_timer.wait_time = rng.randf_range(10, 60)
	bonk_timer.start()

func send_item():
	if delivery_hydrophone.visible == true:
		delivery_hydrophone.visible = false


func _on_creak_timer_timeout():
	creaks.get_children()[rng.randi() % creaks.get_child_count()].play()
	creak_timer.wait_time = rng.randf_range(10, 60)
	creak_timer.start()
