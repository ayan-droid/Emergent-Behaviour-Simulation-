extends CharacterBody2D

var speed = 10000
var randomdir = RandomNumberGenerator.new()
var randomtime = RandomNumberGenerator.new()
var wait_time
var other_wait_time
var movement
var angle 
var current_area
var food_position : Vector2
var pheromone_position : Vector2
var food_consumed = 0
var time_between_pheromone_drops = 1
var areapos = ""
var a = ""
var priority = 3
var current_angle
var going_home = false
var following_food = false
var area_position
var area_name
var full : bool = false
var new_angle
var upper = 60
var lower = -60
var time10 = 1000
var agent_id = -1
var ToFood = preload("res://scenes/ToFood.tscn")
var ToEnemy = preload("res://scenes/ToEnemy.tscn")
var time_following_to_home = 0
var new_velocity : Vector2
#using states learned about them here https://www.gdquest.com/tutorial/godot/design-patterns/finite-state-machine/
enum States {random_moving,going_to_food,going_home,following_food,none}
var _state : int = States.random_moving
var already_followed_to_home = []
var already_followed_to_food = []
var place_enemy_markers_timeout = 0

func random_direction():
	rotation = randomdir.randf_range(rotation-(PI/6),rotation+(PI/6))
	velocity = Vector2.RIGHT.rotated(rotation)
	_state = States.random_moving
	#Converts angle to vector
	#https://www.reddit.com/r/godot/comments/gh46hy/is_there_a_way_to_convert_an_angle_to_vector2/
	#Creates random rotation for movement and finds the vector based on angle
	
func random_time():
	wait_time = randomtime.randf_range(1,3)
	$RandomMovementTimer.set_wait_time(wait_time)
	$RandomMovementTimer.start()
	

# Called when the node enters the scene tree for the first time.

func _on_foodate(body):
	if self == body:
		food_consumed+=1
		_state = States.going_home
		velocity = -1*velocity
		rotation = velocity.angle()
		already_followed_to_food = []
		full = true
	

func _on_returned_home(body):
	if full==true and self==body:
		full = false
		_state = States.following_food
		food_consumed=0
		global.increase_food.emit()
		velocity = -1*velocity
		rotation = velocity.angle()
		$PheromoneSpawnTimer.start()
		already_followed_to_home = []
		
func _on_go_home(body):
	pass
	'''
	if _state == States.going_home and self == body and full == true:
		velocity = ((get_viewport_rect().size / 2) - global_position).normalized()
		rotation = velocity.angle()
		print("yeo")
		print("Yallah abbas")
	'''
		
func _ready():
	#get_viewport().size = Vector2i(1980,1080)
	var timer1 = $RandomMovementTimer
	var timer2 = $PheromoneSpawnTimer
	var timer3 = $pheromoneFollowRandomTimer
	timer1.timeout.connect(_on_timer_timeout_move)
	timer2.timeout.connect(_on_timer_timeout_pheromone)
	timer3.timeout.connect(_on_pheromone_follow_random_timer)
	global.foodate.connect(_on_foodate)
	global.returned_home.connect(_on_returned_home)
	global.gohome.connect(_on_go_home)
	random_direction()
	random_time()
	#Runs _on_timer_timeout when timer is finished
	# line 12 gotten from https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html#connecting-a-signal-via-code
	# Struggled with this and took a long time to figure out how to connect functions smh.
	#random_time()
	
func _on_timer_timeout_move():
	if _state!=States.going_home:
		_state = States.none

func _on_timer_timeout_pheromone():
	if _state==States.going_home:
		$PheromoneSpawnTimer.stop()
	else:
		global.place_to_home.emit(global_position,self)

func _on_pheromone_follow_random_timer():
	_state = States.none
	pass

func _physics_process(delta):
	place_enemy_markers_timeout+=delta
	var all_overlaps =$Area2D.get_overlapping_areas()
	var bad_overlaps = $Forchecking.get_overlapping_areas()
	var good_overlaps = []
	for i in all_overlaps:
		if i not in bad_overlaps:
			good_overlaps.append(i)
	
	for i in good_overlaps:
		if i.get_parent().name == "ToFood" and _state == States.random_moving:
			_state = States.following_food
	for i in all_overlaps:
		if i.get_parent().name == "Food" and full == false:
			_state = States.going_to_food	
		elif i.get_parent().name == "Civilisation_Hub" and _state == States.going_home:	
			velocity = (i.global_position- global_position).normalized()
			rotation = velocity.angle()
		elif i.get_parent().name == "Predator" and place_enemy_markers_timeout >1:
			global.place_to_enemy.emit(global_position)
			place_enemy_markers_timeout = 0
			
	match _state:
		States.none:
			_state = States.random_moving
			random_direction()
			random_time()
		States.random_moving:
			pass	
		States.going_home:
			time_following_to_home+=delta
			time10+=delta
			var pheromone_positions = []
			for i in range(good_overlaps.size()):
				if good_overlaps[i].get_parent().name == "ToHome":
					if good_overlaps[i].get_parent().get_parent().owner1 == self:
						pheromone_positions.append(good_overlaps[i])
			var shortest_distance = 1000
			var pheromone_to_follow
			for i in pheromone_positions:
				var y = i.global_position.distance_to(Vector2(604, 309))
				if y<shortest_distance:
					shortest_distance = y
					pheromone_to_follow = i.global_position
			if type_string(typeof(pheromone_to_follow)) == "Vector2" and pheromone_to_follow not in already_followed_to_home:
				velocity = (pheromone_to_follow - global_position).normalized()
				already_followed_to_home.append(pheromone_to_follow)
				rotation = velocity.angle()
			
			
			if time10>0.5:
				global.place_to_food.emit(global_position)
				time10=0

		States.following_food:
			
			var pheromone_positions = []
			for i in range(good_overlaps.size()):
				if good_overlaps[i].get_parent().name == "ToFood":
					pheromone_positions.append(good_overlaps[i])
			var shortest_distance = 1000
			var largest_distance = -1
			var pheromone_to_follow
			var shortlisted = []
			for i in pheromone_positions:
				var y = i.global_position.distance_to(global_position)
				var z = i.global_position.distance_to(get_viewport_rect().size / 2 )
				if y<shortest_distance:
					y = shortest_distance
					shortlisted.append(i)
			for i in shortlisted:
				var z = i.global_position.distance_to(get_viewport_rect().size / 2 )
				if z>largest_distance:
					largest_distance = z
					pheromone_to_follow = i.global_position
			if type_string(typeof(pheromone_to_follow)) == "Vector2" and pheromone_to_follow not in already_followed_to_food:
				velocity = (pheromone_to_follow - global_position).normalized()
				already_followed_to_food.append(pheromone_to_follow)
				rotation = velocity.angle()
			
		States.going_to_food:
			var food_positions = []
			for i in range(all_overlaps.size()):
				if all_overlaps[i].get_parent().name == "Food":
					food_positions.append(all_overlaps[i])
			var shortest_distance = 1000
			var food_to_follow
			for i in food_positions:
				var x = self.global_position.distance_to(i.global_position)
				if x<shortest_distance:
					x = shortest_distance
					food_to_follow = i.global_position
			if type_string(typeof(food_to_follow)) == "Vector2":
				velocity = (food_to_follow - global_position).normalized()
				rotation = rad_to_deg(velocity.angle())		
		
	var movement = move_and_collide(velocity)
	if movement and "Wall" in movement.get_collider().get_parent().name:
		velocity = velocity.bounce(movement.get_normal())
		rotation = velocity.angle()


	
