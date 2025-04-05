extends Node
# Reference to your message terminal
@onready var terminal = $MessageTerminal
# Test messages to display
var test_messages = [
	{"sender": "SYSTEM", "message": "Terminal boot sequence initiated..."},
	{"sender": "ADMIN", "message": "Welcome to the secure messaging system."},
	{"sender": "COMMANDER", "message": "All stations report status immediately."},
	{"sender": "ENGINEERING", "message": "Reactor core stable at 94% capacity."},
	{"sender": "SCIENCE", "message": "Anomaly detected in sector 7-G. Investigating."},
	{"sender": "SYSTEM", "message": "Terminal boot sequence initiated..."},
	{"sender": "ADMIN", "message": "Welcome to the secure messaging system."},
	{"sender": "COMMANDER", "message": "All stations report status immediately."},
	{"sender": "ENGINEERING", "message": "Reactor core stable at 94% capacity."},
	{"sender": "SYSTEM", "message": "Terminal boot sequence initiated..."},
	{"sender": "ADMIN", "message": "Welcome to the secure messaging system."},
	{"sender": "COMMANDER", "message": "All stations report status immediately."},
	{"sender": "ENGINEERING", "message": "Reactor core stable at 94% capacity."}
]
# Index to track which message we're on
var current_message_index = 0
# Timer to space out test messages
var message_timer = null
# Flag to track if a message is currently being displayed
var is_message_in_progress = false

func _ready():
	# Create and configure the timer
	message_timer = Timer.new()
	message_timer.wait_time = 5.0  # 5 seconds between messages
	message_timer.one_shot = false
	message_timer.timeout.connect(_on_message_timer_timeout)
	add_child(message_timer)
	
	# Start the timer
	message_timer.start()
	
	# Show the first message immediately
	display_next_test_message()

func _on_message_timer_timeout():
	# Only display next message if we're not already displaying one
	if not is_message_in_progress:
		display_next_test_message()

func display_next_test_message():
	if current_message_index < test_messages.size():
		var msg = test_messages[current_message_index]
		print("Displaying message: " + msg.sender + " - " + msg.message)
		
		is_message_in_progress = true
		terminal.show_message(msg.sender, msg.message)
		current_message_index += 1
		
		# Set a timer to mark when the message is finished
		var finish_timer = Timer.new()
		finish_timer.wait_time = calculate_message_duration(msg.message)
		finish_timer.one_shot = true
		finish_timer.timeout.connect(func(): is_message_in_progress = false)
		add_child(finish_timer)
		finish_timer.start()
	else:
		# All messages displayed, stop the timer
		print("All messages displayed")
		message_timer.stop()

# Calculate approximately how long it will take to display a message
func calculate_message_duration(message: String) -> float:
	# Basic formula: character_delay × number of characters + pause_after_sender
	# Add some buffer time to be safe
	var char_length = message.length() + 30  # +30 for timestamp and FROM: prefix
	return (char_length * 0.1) + 0.8 + 1.0  # character_delay + pause + buffer
	
# For manual testing with keyboard input
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			# Press space to display the next message immediately
			# Only if we're not already displaying one
			if not is_message_in_progress:
				display_next_test_message()
		elif event.keycode == KEY_R:
			# Press R to reset and start over
			current_message_index = 0
			is_message_in_progress = false
			message_timer.start()
