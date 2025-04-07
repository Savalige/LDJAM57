extends HBoxContainer
class_name HydrophoneComponent

var label_name: String = ""
var label_deployment: String = ""
var active: bool = false
var id: int

# Called when the node enters the scene tree for the first time.
func _ready():
	$Name.text = label_name
	$Deployment.text = label_deployment


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Deployment.text = label_deployment


func _on_check_button_toggled(toggled_on):
	active = toggled_on
