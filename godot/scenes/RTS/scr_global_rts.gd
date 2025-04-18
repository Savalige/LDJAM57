extends Node

class Drone:
	enum State {IDLE, MOVING, DESTROID}
	enum HoldType {EMPTY, HYDROPHONE}
	
	const speed : float = 10
	const speed_rotation : float = PI/6
	
	const pickup_range_square : float = 10*10
	
	var pos    : Vector2
	var angle  : float
	var target : Vector2
	var state  : State
	
	var holding = null
	var hold_type = HoldType.EMPTY
	
	func _init(pos : Vector2, angle : float) -> void:
		self.pos = pos
		self.angle = angle
		self.target = Vector2.ZERO
		self.state = State.IDLE
	
	func physics_step(delta):
		if self.state == State.MOVING:
			if self.pos.distance_to(self.target) < speed*delta: # Snap to position and stop
				self.pos = self.target
				self.state = State.IDLE
			else: # Rotate towards target
				var diff = self.pos.angle_to_point(self.target) - self.angle
				diff = wrap(diff, -PI, PI)
				if abs(diff) < .01:
					self.pos += self.pos.direction_to(self.target)*speed*delta
				else:
					self.angle += sign(diff) * min(speed_rotation * delta, abs(diff))
			
			if holding != null:
				holding.pos = self.pos
	
	func set_target(target : Vector2):
		if self.state == State.DESTROID:
			return
		
		self.target = target
		self.state = State.MOVING

class Hydrophone:
	enum State {DEPLOYED, CARRIED, IN_BASE}
	var pos   : Vector2
	var state : State
	var active : bool
	
	func _init(pos : Vector2):
		self.pos = pos
		self.state = State.IN_BASE
		self.active = true

class Monster:
	enum State {IDLE, ROAMING, INVESTIGATE}
	var rng : RandomNumberGenerator
	
	const speed : float = 15
	const speed_rotation : float = PI/20
	const investigate_rotation : float = PI/4
	const swim_angle : float = PI/5
	
	const sight_range : float = 10
	const attention_sence : float = 10
	
	var pos : Vector2
	var angle  : float
	var target : Vector2
	var state : State
	var swim_direction : int
	var last_attention : float
	
	func _init(pos : Vector2, angle : float):
		rng = RandomNumberGenerator.new()
		rng.randomize()
		
		self.pos = pos
		self.angle = angle
		self.target = Vector2.ZERO
		self.state = State.IDLE
		self.swim_direction = 1
		self.last_attention = 0
	
	func physics_step(delta):
		if self.state != State.IDLE:
			if self.state == State.INVESTIGATE:
				self.last_attention -= delta
				if self.last_attention <= 0: # Abort investigate
					reached_target()
				
			if self.pos.distance_squared_to(self.target) < sight_range*sight_range:
#				self.pos = self.target
				reached_target()
			else: # Rotate towards target
				var diff = self.pos.angle_to_point(self.target) - self.angle
				diff = wrap(diff, -PI, PI)
				
				if abs(diff) > swim_angle:
					swim_direction = sign(diff)
				
				self.angle += delta * swim_direction * (investigate_rotation if self.state == State.INVESTIGATE else speed_rotation)
				self.pos += Vector2.RIGHT.rotated(self.angle)*delta*speed*(Vector2.RIGHT.rotated(self.angle).dot(self.pos.direction_to(self.target)) if self.state == State.INVESTIGATE else 1)
	
	func detect_attention(pos : Vector2, strength : float) -> void:
		var attention = strength - self.pos.distance_to(pos)
		if  attention >= max(attention_sence, self.last_attention):
			self.last_attention = attention
			self.state = State.INVESTIGATE
			self.target = pos
	
	func reached_target():
		self.state = State.IDLE

class Roamer extends Monster:
	var area : Rect2
	var swim_delay : float
	
	var swim_delay_min : float
	var swim_delay_max : float
	
	func _init(pos : Vector2, angle : float, area : Rect2, min : float, max : float):
		super(pos, angle)
	
		self.area = area
		self.swim_delay_min = min
		self.swim_delay_max = max
		
		self.state = State.ROAMING
		self.target = Vector2(rng.randf_range(area.position.x, area.position.x+area.size.x), rng.randf_range(area.position.y, area.position.y+area.size.y))
		self.swim_delay = rng.randf_range(swim_delay_min, swim_delay_max)
	
	func physics_step(delta):
		super(delta)
		
		swim_delay -= delta
		if swim_delay <= 0 and state == State.ROAMING:
			self.target = Vector2(rng.randf_range(area.position.x, area.position.x+area.size.x), rng.randf_range(area.position.y, area.position.y+area.size.y))
			self.swim_delay = rng.randf_range(swim_delay_min, swim_delay_max)
	
	func reached_target():
		self.last_attention = 0
		self.state = State.ROAMING
		self.target = Vector2(rng.randf_range(area.position.x, area.position.x+area.size.x), rng.randf_range(area.position.y, area.position.y+area.size.y))
		self.swim_delay = rng.randf_range(swim_delay_min, swim_delay_max)

class PointOfInterest:
	const detect_range_squared = 75*75
	
	var pos          : Vector2
	var id           : int
	var visible      : bool
	var investigated : bool
	
	func _init(pos : Vector2, id : int, visible):
		self.pos = pos
		self.id = id
		self.visible = visible
		self.investigated = false

var drones : Array[Drone] = [
	Drone.new(Vector2(550, 500), 0),
	Drone.new(Vector2(500, 450), -PI/2),
	Drone.new(Vector2(450, 500), PI),
	Drone.new(Vector2(500, 550), PI/2)
]

var hydrophones : Array[Hydrophone] = [
	Hydrophone.new(Vector2(200, 200))
]

var monsters : Array[Monster] = [
	Roamer.new(Vector2(500, 850), -PI/2, Rect2(0, 700, 1000, 300), 15, 50),
	Roamer.new(Vector2(850, 500), PI, Rect2(700, 0, 300, 1000), 15, 50),
	Roamer.new(Vector2(800, 800), -PI*3/4, Rect2(600, 600, 400, 400), 20, 20)
]

var points_of_interest = [
	PointOfInterest.new(Vector2(100, 100), 1, false)
]

enum BaseBox {EMPTY, HYDROPHONE}
var base_box = BaseBox.EMPTY
var base_pos = Vector2(500, 500)
var base_radius_squared = 75*75

func _ready():
	pass

func physics_step(delta):
	# Drones
	for d in drones:
		d.physics_step(delta)
		if d.state == Drone.State.MOVING:
			emit_attention(d.pos, 100)
			for m in monsters:
				if d.pos.distance_squared_to(m.pos) < 20*20:
					d.state = Drone.State.DESTROID
					break
	
	for m in monsters:
		m.physics_step(delta)

signal base_box_pickup()

func drone_attempt_pickup(id : int) -> bool:
	if drones[id].holding != null:
		return false
	
	if drones[id].pos.distance_squared_to(base_pos) < base_radius_squared:
		if base_box == BaseBox.HYDROPHONE:
			base_box = BaseBox.EMPTY
			
			for h in hydrophones:
				if h.state == Hydrophone.State.IN_BASE:
					h.state = Hydrophone.State.CARRIED
					h.pos = drones[id].pos
					drones[id].holding = h
					drones[id].hold_type = Drone.HoldType.HYDROPHONE
					
					base_box_pickup.emit()
					return true
			push_error("attepted to pickup hydrophone from base, but no hydrophone in base")
			return false
	
	var closest_object = null
	var closest_distance : float = INF
	# Hydrophones
	for h in hydrophones:
		if h.state == Hydrophone.State.CARRIED or h.state == Hydrophone.State.IN_BASE:
			continue
		
		var dist = drones[id].pos.distance_squared_to(h.pos)
		if dist < closest_distance:
			closest_distance = dist
			closest_object = h
	
	if closest_distance <= drones[id].pickup_range_square:
		drones[id].holding = closest_object
		
		# Only if Hydrophone !!!TODO ADD TYPE CHECK!!!
		closest_object.state = Hydrophone.State.CARRIED
		closest_object.pos = drones[id].pos
		return true
	
	return false

signal base_box_drop(type : BaseBox)

func drone_attempt_drop(id : int) -> bool:
	if drones[id].holding == null:
		return false
	
	print_debug(drones[id].pos.distance_squared_to(base_pos))
	if drones[id].pos.distance_squared_to(base_pos) < base_radius_squared:
		if base_box == BaseBox.EMPTY:
			if drones[id].hold_type == Drone.HoldType.HYDROPHONE:
				drones[id].holding.state = Hydrophone.State.IN_BASE
				drones[id].holding.pos = base_pos
				drones[id].holding = null
				drones[id].hold_type = Drone.HoldType.EMPTY
				
				base_box_drop.emit(BaseBox.HYDROPHONE)
				base_box = BaseBox.HYDROPHONE
				return true
		
		return false
	
	drones[id].holding.state = Hydrophone.State.DEPLOYED
	drones[id].holding.pos = base_pos
	drones[id].holding = null
	
	return true

func drone_investigate(id : int) -> int:
	var closest_poi : PointOfInterest = null
	var closest_distance : float = INF
	
	for poi in points_of_interest:
		var dist = drones[id].pos.distance_squared_to(poi.pos)
		if dist > PointOfInterest.detect_range_squared:
			continue
		if dist < closest_distance:
			closest_distance = dist
			closest_poi = poi
	
	if closest_poi != null:
		closest_poi.investigated = true
		return closest_poi.id
	
	return -1

func emit_attention(pos : Vector2, strength : float):
	for m in monsters:
		m.detect_attention(pos, strength)
