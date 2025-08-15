extends CharacterBody2D

enum States {random_moving, going_to_enemy, following_to_enemy, none}
var _state : int = States.random_moving
var randomdir = RandomNumberGenerator.new()
var randomtime = RandomNumberGenerator.new()
var enemy_to_follow
var time = 0
var temp 
var enemy_pheromones

func random_direction():
	rotation = randomdir.randf_range(rotation-(PI/6),rotation+(PI/6))
	velocity = Vector2.RIGHT.rotated(rotation)
	_state = States.random_moving
	#Converts angle to vector
	#https://www.reddit.com/r/godot/comments/gh46hy/is_there_a_way_to_convert_an_angle_to_vector2/
	#Creates random rotation for movement and finds the vector based on angle
	
func random_time():
	var wait_time = randomtime.randf_range(1,3)
	$RandomMovementTimer.set_wait_time(wait_time)
	$RandomMovementTimer.start()

func _on_timer_timeout():
	_state = States.none

func _ready():
	_state = States.random_moving
	var timer = $RandomMovementTimer
	timer.timeout.connect(_on_timer_timeout)
	random_direction()
	random_time()
	
func _physics_process(delta):
	time += delta
	var y = $Area2D.get_overlapping_bodies()
	var g = []
	for i in y:
		if "Predator" in i.get_parent().name:
			g.append(i)
			_state =  States.going_to_enemy
	
	if _state!=States.going_to_enemy:
	
		temp = $Area2D.get_overlapping_areas()
		enemy_pheromones = []
		for i in temp:
			if "ToEnemy" in i.get_parent().name:
				enemy_pheromones.append(i)
				_state = States.following_to_enemy

	
	match _state:
		States.none:
			random_direction()
			random_time()
			
		States.going_to_enemy:
			var shortest_distance = 1000
			for i in g:
				var x = self.global_position.distance_to(i.global_position)
				if x<shortest_distance:
					x = shortest_distance
					enemy_to_follow = i.global_position
			if type_string(typeof(enemy_to_follow)) == "Vector2" and time>0.5:
				velocity = (enemy_to_follow - global_position).normalized()
				rotation = rad_to_deg(velocity.angle())	
				time = 0
		
		States.following_to_enemy:
			var shortest_distance = 1000
			var pheromone_to_follow
			for i in enemy_pheromones:
				var b = i.global_position.distance_to(global_position)
				if b<shortest_distance:
					b = shortest_distance
					pheromone_to_follow = i.global_position

			if type_string(typeof(pheromone_to_follow)) == "Vector2":
				velocity = (pheromone_to_follow - global_position).normalized()
				rotation = velocity.angle()
				_state = States.none
		
		
	var movement = move_and_collide(velocity)
	if movement and "Predator" in movement.get_collider().get_parent().name:
		var rand = randi_range(1,2)
		if rand == 1:
			global.kill.emit(movement.get_collider().get_parent())
			_state =  States.random_moving
		elif rand == 2:
			self.queue_free()
	elif movement and "Wall" in movement.get_collider().get_parent().name:
		velocity = velocity.bounce(movement.get_normal())
		rotation = velocity.angle()
