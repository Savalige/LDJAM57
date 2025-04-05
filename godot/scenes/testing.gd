extends Node
# Reference to your message terminal
@onready var terminal = $MessageTerminal
# Test messages to display
var test_messages = [
	{"sender": "SYSTEM", "message": "Terminal boot sequence initiated..."},
	{"sender": "ADMIN", "message": "Welcome to the secure messaging system."},
	{"sender": "CAPTAIN", "message": "This is a longer test message to see how the terminal handles multi-line content. Please ensure all systems are operational and standing by for further instructions from central command."},
	{"sender": "COMMUNICATIONS", "message": "Incoming transmission from headquarters: All personnel should prepare for inspection at 0800 hours tomorrow. Documentation and system logs should be updated and ready for review. Department heads will be held responsible for any discrepancies."},
	{"sender": "COMMANDER", "message": "All stations report status immediately."},
	{"sender": "ENGINEERING", "message": "Reactor core stable at 94% capacity."},
	{"sender": "SCIENCE", "message": "Anomaly detected in sector 7-G. Investigating."},
	{"sender": "SECURITY", "message": "Attention all personnel. Security protocols have been elevated to level 3. All non-essential movement between sectors is restricted. Authorization codes will be required for all terminal access beyond basic functions."},
	{"sender": "MEDICAL", "message": "Medical bay reports increased cases of radiation sickness in engineering staff. All personnel who worked in sector 4 during the last 72 hours must report to medical for immediate screening and potential treatment."},
	{"sender": "ENGINEERING", "message": "Warning: Primary reactor coolant systems showing fluctuations in pressure valves 7 through 12. Backup systems engaged. Engineering team alpha dispatched to investigate. Recommend power conservation measures until resolved."},
	{"sender": "SYSTEM", "message": "Terminal boot sequence initiated..."},
	{"sender": "ADMIN", "message": "Welcome to the secure messaging system."},
	{"sender": "CAPTAIN", "message": "This is a longer test message to see how the terminal handles multi-line content. Please ensure all systems are operational and standing by for further instructions from central command."},
	{"sender": "COMMUNICATIONS", "message": "Incoming transmission from headquarters: All personnel should prepare for inspection at 0800 hours tomorrow. Documentation and system logs should be updated and ready for review. Department heads will be held responsible for any discrepancies."},
	{"sender": "COMMANDER", "message": "All stations report status immediately."},
	{"sender": "ENGINEERING", "message": "Reactor core stable at 94% capacity."},
	{"sender": "SCIENCE", "message": "Anomaly detected in sector 7-G. Investigating."},
	{"sender": "SECURITY", "message": "Attention all personnel. Security protocols have been elevated to level 3. All non-essential movement between sectors is restricted. Authorization codes will be required for all terminal access beyond basic functions."},
	{"sender": "MEDICAL", "message": "Medical bay reports increased cases of radiation sickness in engineering staff. All personnel who worked in sector 4 during the last 72 hours must report to medical for immediate screening and potential treatment."}
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

# Calculate how long it will take to display a message
func calculate_message_duration(message: String) -> float:
	# Format the message the same way the terminal does
	var formatted_message = "[" + Time.get_time_string_from_system() + "] 0xCAFE \nSRC:   " + test_messages[current_message_index].sender + "\nMSG:  " + message
	
	# Get the actual character delay and pause duration from the terminal
	var char_delay = terminal.character_delay
	var pause_duration = terminal.pause_after_sender
	
	# Calculate total typing time:
	# 1. Character delay times total characters
	# 2. Plus the pause after sender line
	return (formatted_message.length() * char_delay) + pause_duration
	
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
