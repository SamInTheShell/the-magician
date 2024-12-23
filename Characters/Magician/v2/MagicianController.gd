extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var puppet : MagicianPuppet = $MagicianPuppet

func _physics_process(delta: float) -> void:
	camera_movement_input_handler(delta)
	movement_animation_input_handler(delta)
	
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

## TODO: Just redo this trash camera rigging solution...
func camera_movement_input_handler(_delta: float) -> void:
	var _input_vector : Vector2 = Global.get_camera_input_vector()
	## TODO: consume the input vector
	#if input_vector != Vector2.ZERO: print("camera_movement: ", input_vector)
	
	#$SpringArm3D.rotation.y += input_vector.x * delta * 5
	#$CameraYaw/CameraPitch.rotation.x += input_vector.y * delta * -1
	

func movement_animation_input_handler(_delta: float) -> void:
	var input_vector : Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	## TODO: Update this placeholder with physics.
	if input_vector != Vector2.ZERO:
		puppet.standup()
		
		if Input.is_action_pressed("locomotion_fast"):
			puppet.locomotion_state_machine.travel("Running")
		else:
			puppet.locomotion_state_machine.travel("Walking")
	else:
		puppet.locomotion_state_machine.travel("Idle")
	
	if Input.is_action_just_pressed("jump_button"): puppet.jump()
	if Input.is_action_just_pressed("action_button"): puppet.OneHanded_Ranged_Shot()
	if Input.is_action_just_pressed("interaction_button"): puppet.laydown()
