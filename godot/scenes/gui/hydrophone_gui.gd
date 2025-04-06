extends Control

@export var item: PackedScene
@onready var items: Node = $Items

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(len(ScrGlobalRts.hydrophones)):
		var temp = item.instantiate()
		temp.position.y = i * 50
		items.add_child(temp)
		print("here")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
