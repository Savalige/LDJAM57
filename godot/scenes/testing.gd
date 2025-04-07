extends Node
# Reference to your message terminal
@onready var terminal = $MessageTerminal
# Test messages to display
var test_messages = [
	{"sender": "SYSTEM", "message": "Terminal boot sequence initiated... Hadopelagic Research Station online. Solitary operator protocol active."},
	{"sender": "MARIANA_CORP", "message": "Operator, drones 1-4 are online and awaiting deployment. Begin standard collection procedure in sector 7."},
	{"sender": "COMMS_RELAY", "message": "Surface communications check complete. Direct terminal connections stable. Note: Only external drone communications may experience degradation at these depths."},
	{"sender": "DRONE_3", "message": "Error in collection apparatus. Drone returning to dock for automated repair sequence."},
	{"sender": "MARIANA_CORP", "message": "Quarterly targets increased by 15%. Board expects significant return on our investment in Hadopelagic Mining Initiative. Additional drone deployments authorized. Remember: you're being compensated extremely well for your isolation. Deliver results."},
	{"sender": "OCEANICS", "message": "External pressure anomaly detected. Hull integrity at 92% and stable. Automated reinforcement sequence initiated in lower compartments."},
	{"sender": "STATION_AI", "message": "Oxygen recirculation system operating at reduced capacity. CO2 scrubbers showing intermittent failures. Automated diagnostic reveals potential blockage in filtration intake. Recommend manual inspection when convenient."},
	{"sender": "MARIANA_CORP", "message": "Your last sample collection shows promising results. Biological material in sector 9-D demonstrates unusual properties. Deploy Drone 2 with specialized collection unit. Priority upgrade: Obtain larger specimens."},
	{"sender": "DRONE_1", "message": "Warning: Unexpected resistance encountered during collection. Specimen appears to have damaged sampling apparatus. External camera feed compromised. Drone returning to dock with partial sample."},
	{"sender": "STATION_AI", "message": "Unusual energy signature detected near thermal vent in sector 12. Recommend drone investigation after maintenance cycle complete."},
	{"sender": "MARIANA_CORP", "message": "Preliminary analysis of Sample 347-B shows remarkable cellular regeneration and adaptation to extreme pressure. The board is extremely pleased. Your bonus has been increased. Continue collection in the same region, and deploy the extended-range drone to map the surrounding area for similar biological signatures. We're making history here, operator. The applications of these organisms could revolutionize medicine, materials science, and more. Your isolation is serving a greater purpose."},
	{"sender": "DRONE_4", "message": "Error: Navigation systems compromised. External sensors detecting multiple moving objects in vicinity. Unable to establish visual confirmation. Drone returning to base on emergency protocol."},
	{"sender": "STATION_AI", "message": "Warning: External microphone arrays detecting unusual sonic patterns. Frequency analysis does not match known deep-sea biological sources. Recording saved to database."},
	{"sender": "DRONE_2", "message": "Collection complete. Sample secured. Note: Specimen exhibited unusual bioluminescent response during collection process. Possible defense mechanism. Further study recommended."},
	{"sender": "MARIANA_CORP", "message": "We've lost contact with research vessel Hermes that was scheduled for your next supply drop. Alternative arrangements being made. Continue operations as normal. Current oxygen and supply levels sufficient for extended operation."},
	{"sender": "STATION_AI", "message": "Multiple electrical anomalies detected in station circuitry. Possible interference from unknown source. Some systems switching to backup power. Diagnostic routine initiated."},
	{"sender": "DRONE_1", "message": "WARNING: Catastrophic damage sustained during deployment. Last transmission indicates contact with unidentified organism. Estimated size exceeds prediction models for this depth. Drone signal lost."},
	{"sender": "STATION_AI", "message": "External pressure increasing beyond normal parameters. Multiple hull stress warnings in section 3. Automated bulkheads engaged. Recommend restricting movement to central operations area until pressure stabilizes."},
	{"sender": "DRONE_3", "message": "Footage captured of unusual organic structures near thermal vent. Structures appear to be artificial or semi-artificial in nature. Biological samples collected. Analysis pending."},
	{"sender": "MARIANA_CORP", "message": "URGENT: Do NOT collect additional specimens from sector 12. Repeat, cease all collection activities in sector 12 immediately. Initial analysis of returned samples indicates potentially hazardous biological properties. Samples are exhibiting rapid mutation and unusual resistance to containment protocols on the surface. Secure all collected materials in high-level quarantine storage. Stand by for emergency evacuation protocol."},
	{"sender": "STATION_AI", "message": "WARNING: Automated systems detecting multiple impacts against exterior hull. Pattern suggests deliberate contact rather than debris. Analysis of impact frequency indicates organized activity."},
	{"sender": "MARIANA_CORP", "message": "Communication relay from surface compromised. Switching to emergency band. Be advised: Evacuation pod deployment delayed due to severe surface weather. Estimated arrival of recovery vessel: 72 hours. Maintain quarantine protocols. Do NOT examine specimens directly under any circumstances."},
	{"sender": "STATION_AI", "message": "Critical alert: Unusual growth detected in ventilation system near drone bay. Biological matter spreading at accelerated rate. Automated containment systems activated. Quarantine doors sealed."},
	{"sender": "DRONE_4", "message": "ERROR: Drone dock breach detected. Foreign biological material present in mechanical systems. Automated sterilization sequence initiated. Sterilization failure. Repeat: sterilization failure."},
	{"sender": "STATION_AI", "message": "EMERGENCY PROTOCOL DELTA: Multiple system failures detected. Foreign organic material spreading through station infrastructure. Power systems compromised. Switching to emergency reserves. Recommend immediate retreat to secure operations center and manual activation of evacuation pod."},
	{"sender": "MARIANA_CORP", "message": "...signal breaking up... recovery team... aware of situation... delay expected... containment priority alpha... use emergency protocols... no direct contact with... specimens show aggressive cellular... documented symptoms include... not alone down there... it adapts quickly... God forgive us for sending..."},
	{"sender": "STATION_AI", "message": "WARNING: Primary systems failing. Foreign biological matter interfering with electrical systems. Emergency evacuation strongly recommended. Something is coming through the ventilation system. It's approaching the main terminal room. You need to leave NOW."}
]

# Index to track which message we're on
var current_message_index = 0
# Timer to space out test messages
var message_timer = null
# Flag to track if a message is currently being displayed
var is_message_in_progress = false
# Random time range for messages
@export var min_delay = 4.0
@export var max_delay = 12.0
# Timer for finishing messages
var finish_timer = null

func _ready():
	# Create and configure the timer
	message_timer = Timer.new()
	message_timer.wait_time = get_random_delay()
	message_timer.one_shot = false
	message_timer.timeout.connect(_on_message_timer_timeout)
	add_child(message_timer)
	
	# Create a single reusable finish timer
	finish_timer = Timer.new()
	finish_timer.one_shot = true
	finish_timer.timeout.connect(func(): is_message_in_progress = false)
	add_child(finish_timer)
	
	# Start the timer
	message_timer.start()
	
	# Show the first message immediately
	display_next_test_message()

func _on_message_timer_timeout():
	# Only display next message if we're not already displaying one
	if not is_message_in_progress:
		display_next_test_message()
		
	# Set a new random delay for the next message
	message_timer.wait_time = get_random_delay()

func get_random_delay() -> float:
	return randf_range(min_delay, max_delay)

func display_next_test_message():
	if current_message_index < test_messages.size():
		var msg = test_messages[current_message_index]
		
		is_message_in_progress = true
		terminal.show_message(msg.sender, msg.message)
		current_message_index += 1
		
		# Reuse the finish timer
		finish_timer.wait_time = calculate_message_duration(msg.message)
		finish_timer.start()
	else:
		# Instead of stopping, loop back to beginning with a longer delay
		current_message_index = 0
		message_timer.wait_time = max_delay * 1.5  # Longer pause before restarting
		is_message_in_progress = false

# Calculate how long it will take to display a message
func calculate_message_duration(message: String) -> float:
	# Format the message the same way the terminal does
	var formatted_message
	if current_message_index > 0:
		formatted_message = "[" + Time.get_time_string_from_system() + "] 0xCAFE \nSRC:   " + test_messages[current_message_index-1].sender + "\nMSG:  " + message
	else:
		formatted_message = "[" + Time.get_time_string_from_system() + "] 0xCAFE \nSRC:   SYSTEM\nMSG:  " + message
	
	# Get the actual character delay and pause duration from the terminal
	var char_delay = terminal.character_delay
	var pause_duration = terminal.pause_after_sender
	
	return (formatted_message.length() * char_delay) + pause_duration
	
# For manual testing with keyboard input
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_SPACE:
			if not is_message_in_progress:
				display_next_test_message()
		elif event.keycode == KEY_R:
			current_message_index = 0
			is_message_in_progress = false
			message_timer.start()
