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

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
	knockback = move_and_slide(knockback)
	match state:
		idle:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			seek_player()
		wander:
			pass
		chase:
			var player = playerDetectionZone.player
			if player != null:
				var direction = position.direction_to(player.global_position)
				#var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
			else:
				state = idle
			
			# esto significa la linea sprite.flip_h = velocity.x < 0
			# if velocity.x < 0: sprite.flip_f = true else: sprite.flip_h = false
			sprite.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)

func seek_player():
	if playerDetectionZone.can_see_player():
		state = chase

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
