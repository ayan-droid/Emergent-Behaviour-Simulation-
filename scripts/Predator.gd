extends CharacterBody2D

enum States {going_to_agent,going_to_hub}
var _state : int = States.going_to_hub
var new_velocity
var agent_to_follow
var time = 0
var timer2 = 0
var kill_cooldown = 0

func _ready():
	pass


func _physics_process(delta):
	time+=delta
	timer2+=delta
	kill_cooldown+=delta
	var y = $Area2D.get_overlapping_bodies()
	var g = []
	for i in y:
		if "FoodGatherer" in i.get_parent().name or "Fighter" in i.get_parent().name or "Scouter" in i.get_parent().name:
			g.append(i)
			_state =  States.going_to_agent

	match _state:
		States.going_to_hub:
			velocity = (Vector2(604, 309) - global_position).normalized()
		States.going_to_agent:
			var shortest_distance = 1000
			for i in g:
				var x = self.global_position.distance_to(i.global_position)
				if x<shortest_distance:
					x = shortest_distance
					agent_to_follow = i.global_position
			if type_string(typeof(agent_to_follow)) == "Vector2" and time>0.5:
				velocity = (agent_to_follow - global_position).normalized()
				rotation = rad_to_deg(velocity.angle())	
				time = 0
	var movement = move_and_collide(velocity)
	if movement:
		if "FoodGatherer" in movement.get_collider().get_parent().name and kill_cooldown>2:
			global.kill.emit(movement.get_collider().get_parent())
			_state =  States.going_to_hub
			kill_cooldown = 0
		elif "Civilisation_Hub" in movement.get_collider().get_parent().name and timer2>3:
			global.damage_taken.emit()
			timer2 = 0
		elif "Fighter" in movement.get_collider().get_parent().name and kill_cooldown>2:
			var rand = randi_range(1,2)
			kill_cooldown = 0
			if rand == 1:
				global.kill.emit(movement.get_collider().get_parent())
				_state =  States.going_to_hub
			elif rand == 2:
				print("Suicide time yay")
				self.queue_free()
