extends Label

var credits = [
	"Rezyn",
	"Savalige",
	"Golahirom",
	"HenrikoMagnifico"
]

func _ready():
	# Randomize the seed
	randomize()
	
	# Shuffle the credits array
	credits.shuffle()
	
	# Build the text with randomized names
	var credit_text = ""
	for name in credits:
		credit_text += name + "\n"
	
	# Set the label text
	text = credit_text.strip_edges()
