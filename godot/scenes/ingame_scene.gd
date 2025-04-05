extends Node2D

@onready var fade_overlay = $Player/%FadeOverlay
@onready var pause_overlay = $Player/%PauseOverlay
@onready var player = $Player
@onready var terminals = $Terminals
@onready var items = $Items
@onready var bonk_timer = $BonkTimer
@onready var bonks = $Bonks

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	fade_overlay.visible = true
	
	for terminal in terminals.get_children():
		terminal.ray = player.ray
		terminal.player = player
	
	if SaveGame.has_save():
		SaveGame.load_game(get_tree())
	
	pause_overlay.game_exited.connect(_save_game)

func _input(event) -> void:
	if event.is_action_pressed("pause") and not pause_overlay.visible:
		get_viewport().set_input_as_handled()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().paused = true
		pause_overlay.grab_button_focus()
		pause_overlay.visible = true
		
func _save_game() -> void:
	SaveGame.save_game(get_tree())


func _on_bonk_timer_timeout():
	bonks.get_children()[rng.randi() % bonks.get_child_count()].play()
	bonk_timer.wait_time = rng.randf_range(10, 60)
	bonk_timer.start()
