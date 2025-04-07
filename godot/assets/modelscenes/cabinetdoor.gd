# cabinetdoor.gd
extends Node3D

# Door state
var is_open = false
var target_rotation = 0.0
var current_rotation = 0.0

# Door settings
@export var open_angle = 120.0  # How far the door opens in degrees
@export var rotation_speed = 2.5  # Speed of door rotation

func _process(delta):
	# Smoothly rotate door to target rotation
	if current_rotation != target_rotation:
		current_rotation = lerp(current_rotation, target_rotation, rotation_speed * delta)
		# Try Y-axis rotation first - this is typically correct for doors
		rotation_degrees.y = current_rotation
		
		# If we're very close to target, snap to it
		if abs(current_rotation - target_rotation) < 0.01:
			current_rotation = target_rotation
			rotation_degrees.y = current_rotation

func open_door():
	is_open = true
	target_rotation = open_angle

func close_door():
	is_open = false
	target_rotation = 0.0
