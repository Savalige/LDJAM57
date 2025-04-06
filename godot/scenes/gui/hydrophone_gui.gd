extends Control

@export var item: PackedScene
@onready var items: Node = $Items

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(len(ScrGlobalRts.hydrophones)):
		var temp: HydrophoneComponent = item.instantiate()
		temp.position.y = i * 50
		temp.label_name = "Hydrophone: "+str(i)
		match ScrGlobalRts.hydrophones[i].state:
			ScrGlobalRts.Hydrophone.State.IN_BASE:
				temp.label_deployment = "In Base"
			ScrGlobalRts.Hydrophone.State.DEPLOYED:
				temp.label_deployment = "Deployed"
			ScrGlobalRts.Hydrophone.State.CARRIED:
				temp.label_deployment = "Carried"
			_:
				print("ERROR: FUCK SHITE FUCK")
		
		items.add_child(temp)
		print("here")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var list = items.get_children()
	for i in range(len(list)):
		match ScrGlobalRts.hydrophones[i].state:
			ScrGlobalRts.Hydrophone.State.IN_BASE:
				list[i].label_deployment = "In Base"
			ScrGlobalRts.Hydrophone.State.DEPLOYED:
				list[i].label_deployment = "Deployed"
			ScrGlobalRts.Hydrophone.State.CARRIED:
				list[i].label_deployment = "Carried"
			_:
				print("ERROR: FUCK SHITE FUCK")
