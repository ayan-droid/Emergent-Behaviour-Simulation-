extends Node
var food_gatherer = preload("res://scenes/foodGatherer.tscn")
var predator =  preload("res://scenes/Predator.tscn")
var fighter = preload("res://scenes/Fighter.tscn")
var current_food = 0
var n = 10
var rot = 360/n
var temp = rot
var time= 0
var num_of_pred = 0
var health = 100
var triggered = false


func _increase_food():
	current_food+=1
	$"../CurrentAmountOfFood".text = str(current_food)+" food collected"



var spawn_point

#https://forum.godotengine.org/t/how-to-generate-random-spawn-point-at-edge-of-screen-only/20661/2
func rand_pos_on_edge():
	var s = randi_range(1,4)
	if s == 1: # top edge
		spawn_point = Vector2(randi_range(0, get_viewport().get_visible_rect().size.x),-30)
	if s == 3: # bottom edge
		spawn_point = Vector2(randi_range(0, get_viewport().get_visible_rect().size.x), get_viewport().get_visible_rect().size.y)
	if s == 2: # right edge
		spawn_point = Vector2(get_viewport().get_visible_rect().size.x, randi_range(-100, get_viewport().get_visible_rect().size.y))
	if s == 4: # left edge
		spawn_point = Vector2(0, randi_range(0, get_viewport().get_visible_rect().size.y))
	return spawn_point	

func _predator_spawn():
	num_of_pred +=1
	var instance = predator.instantiate()
	instance.position = rand_pos_on_edge()
	instance.name = "Predator"+str(num_of_pred)
	add_child(instance)


func _agent_spawn():
	# 1 food for every agent per minute, if there is more then excess agents made and if there are less than some randomly some die
	if current_food<n:
		print("Agents are going to die")
		var dif = n - current_food
		print("Difference ", dif)
		print("Current amount of agents ",n)
		for i in range(dif):
			var x = randi_range(6,n+5) 
			remove_child(get_child(x))
			n-=1
		current_food = 0
		print(n,"  ", current_food)
		print("Numb of agents now ", n)
	elif current_food>n:
		print("New agents are spawned in")
		var dif = current_food - n 
		print("Difference ", dif)
		print("Current number of agents ",n)
		current_food = 0
		for i in range(dif):
			var type = randi_range(1,2)
			if type == 1:
				var instance = food_gatherer.instantiate()
				instance.position = get_child(0).position
				instance.get_child(0).rotation = 0
				instance.name = "FoodGatherer"+str(n+1+dif)
				add_child(instance)
				n+=1
			elif type == 2:
				var instance = fighter.instantiate()
				instance.position =  get_child(0).position
				instance.get_child(0).rotation = 0
				instance.name = "Fighter"+str(n+1+dif)
				add_child(instance)
				n+=1
		print("Numb of agents now ", n)
				
		

		
				
			

func _on_killed(body):
	if is_instance_valid(body):
		n-=1
		remove_child(body)


func _take_damage():
	health-=5
	$"../HealthBar".value = health
	if health<=0:
		global.game_over.emit(time)
		$"../CanvasLayer/SimulationOver".visible = true
		get_tree().paused = true


func _ready():
	$"../HealthBar".value = health
	$"../CurrentAmountOfFood".text = str(current_food)+" food collected"
	global.increase_food.connect(_increase_food)
	global.kill.connect(_on_killed)
	global.damage_taken.connect(_take_damage)
	var center_position = $Area2D.position  # Central point for the agents
	var radius = 50  # Distance from the center to the outermost agent
	var angle_increment = 2 * PI / n  # Angle between each agent
	for i in range(n):
		var type = randi_range(1,2)
		if type == 1:
			var instance = food_gatherer.instantiate()
			var angle = i * angle_increment  # Calculate the angle for this agent
			var x = center_position.x + radius * cos(angle)
			var y = center_position.y + radius * sin(angle)
			instance.position = Vector2(x, y)
			instance.get_child(0).rotation = deg_to_rad(temp)  # Set the initial rotation
			instance.name = "FoodGatherer"+str(i)
			temp+=rot
			add_child(instance)
		elif type == 2:
			var instance = fighter.instantiate()
			var angle = i * angle_increment  # Calculate the angle for this agent
			var x = center_position.x + radius * cos(angle)
			var y = center_position.y + radius * sin(angle)
			instance.position = Vector2(x, y)
			instance.get_child(0).rotation = deg_to_rad(temp)  # Set the initial rotation
			instance.name = "Fighter"+str(i)
			temp+=rot
			add_child(instance)
	
	var timer = $PredatorSpawning
	var timer2 = $Agent_spawning
	timer.timeout.connect(_predator_spawn)
	timer2.timeout.connect(_agent_spawn)
	timer.start()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	$"../Label".text = str(int(time))+" seconds"
	$"../CurrentAmountOfFood".text = str(current_food)+" food collected"
	time+=delta
	



func _on_area_2d_body_entered(body):
	if body.get_parent().get_parent().name == "Civilisation_Hub":
		global.returned_home.emit(body)


func _on_bring_people_home_body_entered(body):
	if body.get_parent().get_parent().name == "Civilisation_Hub":
		global.gohome.emit(body)
