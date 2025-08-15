extends Node2D


var food = preload("res://scenes/food.tscn")
var ToHome = preload("res://scenes/ToHome.tscn")
var ToFood = preload("res://scenes/ToFood.tscn")
var ToEnemy = preload("res://scenes/ToEnemy.tscn")
# Called when the node enters the scene tree for the first time.

var time = 0

func rand_point_in_circle(p_radius = 1.0): # Unit length by default.
	var r = sqrt(randf_range(0.0, 1.0)) * p_radius
	var t = randf_range(0.0, 1.0) * TAU
	return Vector2(r * cos(t), r * sin(t))

func spawn_food():

	for i in range(10):
			var center_x = randi_range(50, 1110) # X range adjusted for the circle's radius
			var center_y = randi_range(50, 600)  # Y range adjusted for the circle's radius
			var radius = 30 # Adjust this value to change the size of the circle
			#while Geometry2D.is_point_in_polygon(Vector2(center_x,center_y),$Civilisation_Hub/WhereFoodCantSpawn.polygon) == true:
				#center_x = randi_range(-300, 1600)
				#center_y = randi_range(-200, 800)
			for j in range(100):
				var instance = food.instantiate()
				var point = rand_point_in_circle(radius)
				instance.position = Vector2(center_x + point.x, center_y + point.y)
				add_child(instance)

	
func _ready():
	randomize()
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	global.place_to_home.connect(_place_to_home)
	global.place_to_food.connect(_place_to_food)
	global.place_to_enemy.connect(_place_to_enemy)
	$Civilisation_Hub/WhereFoodCantSpawn.visible = false
	print($Civilisation_Hub/Area2D.global_position)
	spawn_food()
	

func _place_to_home(position,placer):
	var instance = ToHome.instantiate()
	add_child(instance)
	instance.position = position
	instance.owner1 = placer
	await get_tree().create_timer(40).timeout
	instance.queue_free()

func _place_to_food(position):
	var instance = ToFood.instantiate()
	instance.position = position
	add_child(instance)
	await get_tree().create_timer(40).timeout
	instance.queue_free()

func _place_to_enemy(position):
	var instance = ToEnemy.instantiate()
	instance.position = position
	add_child(instance)
	await get_tree().create_timer(40).timeout
	instance.queue_free()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time+=delta
	if int(time)>120:
		spawn_food()
		time = 0
