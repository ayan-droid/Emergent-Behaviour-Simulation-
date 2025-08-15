extends Area2D



# Called when the node enters the scene tree for the first time.
func _ready():
	self.body_entered.connect(_on_body_entered)
	self.monitoring = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func _on_body_entered(body):
	print(body)
	if body.name == "food":
		print("food nearby")
		print(body)
	
