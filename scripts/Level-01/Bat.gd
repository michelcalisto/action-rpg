extends KinematicBody2D

const EnemyDeathEffect = preload("res://scenes/EnemyDeathEffect.tscn")
export var acceleration = 300
export var max_speed = 50
export var friction = 200
var knockback = Vector2.ZERO
onready var stats = $Stats
enum {idle, wander, chase}
var state = chase
var velocity = Vector2.ZERO
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $HurtBox
onready var softCollision = $SoftCollision 
onready var wanderController = $WanderController

func _ready():
	state = pick_random_state([idle, wander])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
	knockback = move_and_slide(knockback)
	match state:
		idle:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				state = pick_random_state([idle, wander])
				wanderController.start_wander_timer(rand_range(1, 3))
		wander:
			seek_player()
			if wanderController.get_time_left() == 0:
				state = pick_random_state([idle, wander])
				wanderController.start_wander_timer(rand_range(1, 3))

			accelerate_towards_point(wanderController.target_position, delta)
			#var direction = global_position.direction_to(wanderController.target_position)
			#velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
			#sprite.flip_h = velocity.x < 0
			
			if global_position.distance_to(wanderController.target_position) <= 4:
				state = pick_random_state([idle, wander])
				wanderController.start_wander_timer(rand_range(1, 3))
		chase:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
				#var direction = position.direction_to(player.global_position)
				#var direction = (player.global_position - global_position).normalized()
				#velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
			else:
				state = idle
			
			# esto significa la linea sprite.flip_h = velocity.x < 0
			# if velocity.x < 0: sprite.flip_f = true else: sprite.flip_h = false
			#sprite.flip_h = velocity.x < 0
			
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetectionZone.can_see_player():
		state = chase

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
