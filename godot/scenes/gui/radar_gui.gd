extends Control

@onready var timer: Timer = $Timer
var color: Color = Color.RED
var alpha = 0

func _draw():
	for x in range(0, 10):
		draw_line(Vector2(x*50+25,0), Vector2(x*50+25, 500), Color.WHITE)
	for y in range(0, 10):
		draw_line(Vector2(0,y*50+25), Vector2(500, y*50+25), Color.WHITE)
	
	if not timer.is_stopped():
		ScrGlobalRts.emit_attention(Vector2(500, 500), 200)
		var radius = ((timer.wait_time - timer.time_left) / timer.wait_time) * 500
		draw_arc(Vector2(250, 250), 
		radius, 
		0, PI*2, 100, Color.PURPLE)
		
		for e in ScrGlobalRts.monsters:
			var distance = (e.pos/2).distance_to(Vector2(250, 250))
			if distance < radius + 0.5 and distance > radius - 0.5:
				alpha = 1
			color.a = alpha
			draw_circle(e.pos/2, 10, color)
	
	for d in ScrGlobalRts.drones:
		draw_circle(d.pos/2, 10, Color.BLUE)
	for h in ScrGlobalRts.hydrophones:
		draw_line(h.pos/2 + (Vector2.DOWN * 5), h.pos/2 + (Vector2.UP * 5), Color.GREEN, 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if alpha > 0:
		alpha -= 1 * delta
	else:
		alpha = 0
	queue_redraw()


func _on_ping_button_up():
	if timer.is_stopped():
		timer.start()
