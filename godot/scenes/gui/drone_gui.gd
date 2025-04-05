extends Control

var player: Player

@onready var text: LineEdit = $LineEdit
@onready var info: Label = $Info

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _draw():
	draw_rect(Rect2(1.0, 1.0, 3.0, 3.0), Color.GREEN)
	draw_rect(Rect2(5.5, 1.5, 2.0, 2.0), Color.GREEN, false, 1.0)
	draw_rect(Rect2(9.0, 1.0, 5.0, 5.0), Color.GREEN)
	draw_rect(Rect2(16.0, 2.0, 3.0, 3.0), Color.GREEN, false, 2.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	queue_redraw()


func parse(value: String):
	var pos: Vector2 = Vector2.ZERO
	for c in value:
		if not c.is_valid_int():
			c = c.to_lower()
			match c:
				"a":
					pos.x = 50
				"b":
					pos.x = 150
				"c":
					pos.x = 250
				"d":
					pos.x = 350
				"e":
					pos.x = 450
				"f":
					pos.x = 550
				"g":
					pos.x = 650
				"h":
					pos.x = 750
				"i":
					pos.x = 850
				"j":
					pos.x = 950
		if c.is_valid_int():
			pos.y = 50 + (int(c) * 100)
	if pos.x == 0 or pos.y == 0:
		return false
	return pos


func _on_pick_up_button_up():
	pass # Replace with function body.


func _on_drop_button_up():
	pass # Replace with function body.


func _on_line_edit_focus_entered():
	get_parent().get_parent().player.paused = true


func _on_line_edit_focus_exited():
	get_parent().get_parent().player.paused = false


func _on_line_edit_text_submitted(_new_text):
	text.release_focus()
	print(parse(text.text))
	if !parse(text.text):
		info.text = "ERROR: not a valid position"
	text.text = ""
	get_parent().get_parent().player.paused = false
