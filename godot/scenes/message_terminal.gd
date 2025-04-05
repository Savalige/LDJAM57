extends Control
@export var character_delay := 0.08  # Increased from 0.05 to 0.1 for slower typing
@export var pause_after_timestamp := 0.2  # Pause after timestamp
@export var pause_after_sender := 0.2  # Pause between sender and message
@export var auto_close_delay := 2.0
@export var max_history_lines := 1000

var _full_text: String = ""
var _typing_index: int = 0
var _message_history: Array = []
var _current_message: String = ""
var _paused_at_timestamp: bool = false
var _paused_at_sender: bool = false
var _timestamp_pause_position: int = 0
var _sender_pause_position: int = 0
var _is_typing: bool = false

@onready var _rich_text_label := $RichTextLabel
@onready var _char_reveal_timer := $CharRevealTimer
@onready var _audio_player := $AudioStreamPlayer3D

func _ready():
	_char_reveal_timer.timeout.connect(self._on_char_reveal_timeout)
	_char_reveal_timer.wait_time = character_delay
	_char_reveal_timer.one_shot = false
	
	# Disable all scrolling
	_rich_text_label.scroll_active = true
	_rich_text_label.scroll_following = true
	
	# Get the VScrollBar and hide it
	var v_scroll = _rich_text_label.get_v_scroll_bar()
	if v_scroll:
		v_scroll.visible = false

func show_message(sender: String, message: String):
	# Format the message with newlines between timestamp, sender, and message
	var formatted_message = "[" + Time.get_time_string_from_system() + "] \nSOURCE:   " + sender + "\nMESSAGE:  " + message
	
	# Store the positions where we need to pause
	_timestamp_pause_position = formatted_message.find("\n")
	_sender_pause_position = formatted_message.find("\n", _timestamp_pause_position + 1)
	_paused_at_timestamp = false
	_paused_at_sender = false
	
	# Add to history
	_message_history.append(formatted_message)
	_current_message = formatted_message
	
	# Trim history if it gets too long
	if _message_history.size() > max_history_lines:
		_message_history.pop_front()
	
	# Update full text with all history
	_update_display_text()
	
	# Reset typing index for text reveal
	_typing_index = _rich_text_label.text.length() - formatted_message.length()
	_rich_text_label.visible_characters = _typing_index
	
	# Start revealing characters
	_is_typing = true
	_char_reveal_timer.wait_time = character_delay
	_char_reveal_timer.start()

func _update_display_text():
	var display_text = ""
	
	# Add each message with a separator
	for i in range(_message_history.size()):
		if i > 0:
			display_text += "\n \n"  # Space between newlines
		display_text += _message_history[i]
	
	_full_text = display_text
	_rich_text_label.text = _full_text

func _on_char_reveal_timeout():
	# Reveal next character
	if _typing_index < _full_text.length():
		# Calculate relative position within current message
		var relative_position = _typing_index - (_full_text.length() - _current_message.length())
		
		# Check if we need to pause after the timestamp
		if relative_position == _timestamp_pause_position and not _paused_at_timestamp:
			_paused_at_timestamp = true
			_char_reveal_timer.wait_time = pause_after_timestamp
			_char_reveal_timer.start()
			return
		
		# Check if we need to pause after the sender
		if relative_position == _sender_pause_position and not _paused_at_sender:
			_paused_at_sender = true
			_char_reveal_timer.wait_time = pause_after_sender
			_char_reveal_timer.start()
			return
		
		# Continue normal typing
		_typing_index += 1
		_rich_text_label.visible_characters = _typing_index
		
		# Reset to normal typing speed if we were paused
		if _char_reveal_timer.wait_time != character_delay:
			_char_reveal_timer.wait_time = character_delay
		
		# Play typing sound
		if _audio_player and _audio_player.stream:
			_audio_player.play()
	else:
		# We've finished typing this message
		_is_typing = false
		_char_reveal_timer.stop()

# Override _process to ensure we maintain control of visible characters
func _process(delta):
	# This prevents any external code from changing our visible characters
	# during the typing animation
	if _is_typing:
		_rich_text_label.visible_characters = _typing_index

func clear_terminal():
	_message_history.clear()
	_full_text = ""
	_rich_text_label.text = ""
	_rich_text_label.visible_characters = 0
	_is_typing = false
