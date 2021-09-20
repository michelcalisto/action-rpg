extends KinematicBody2D

const acceleration = 500
const max_speed = 80
const friction = 500
const roll_speed = 120
var velocity = Vector2.ZERO
var roll_vector = Vector2.LEFT
enum {move, roll, attack}
var state = move
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	animationTree.active = true

func _physics_process(delta):
	match state:
		move: 
			move_state(delta)
		roll: 
			roll_state(delta)
		attack: 
			attack_state(delta)

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = roll
		
	if Input.is_action_just_pressed("attack"):
		state = attack

func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func attack_animation_finished():
	state = move
	
func roll_state(delta):
	velocity = roll_vector * roll_speed
	animationState.travel("Roll")
	move()
	
func roll_animation_finished():
	velocity = velocity * 0.8
	state = move

func move():
	velocity = move_and_slide(velocity)
