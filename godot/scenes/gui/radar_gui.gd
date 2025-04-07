extends Control

@onready var timer: Timer = $Timer
@onready var ping: AudioStreamPlayer = $PingAudio

var alpha = []

func _ready():
	for e in ScrGlobalRts.monsters:
		alpha.append(0)

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
		
		for i in range(len(ScrGlobalRts.monsters)):
			var distance = (ScrGlobalRts.monsters[i].pos/2).distance_to(Vector2(250, 250))
			if distance < radius + 1 and distance > radius - 1:
				alpha[i] = 1
				ping.play()
			var color: Color = Color.RED
			color.a = alpha[i]
			draw_circle(ScrGlobalRts.monsters[i].pos/2, 10, color)
	
	for d in ScrGlobalRts.drones:
		draw_circle(d.pos/2, 10, Color.BLUE)
	for h in ScrGlobalRts.hydrophones:
		if not h.state == ScrGlobalRts.Hydrophone.State.IN_BASE:
			draw_line(h.pos/2 + (Vector2.DOWN * 5), h.pos/2 + (Vector2.UP * 5), Color.GREEN, 2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in range(len(alpha)):
		if alpha[i] > 0:
			alpha[i] -= 1 * delta
		else:
			alpha[i] = 0
	queue_redraw()


func _on_ping_button_up():
	if timer.is_stopped():
		timer.start()
