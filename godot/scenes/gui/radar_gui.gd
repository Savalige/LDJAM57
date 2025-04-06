extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _draw():
	for d in ScrGlobalRts.drones:
		draw_circle(d.pos/2, 10, Color.BLUE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	queue_redraw()
