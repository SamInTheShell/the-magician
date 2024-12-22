#@tool
extends Node3D

@export var start_hidden: Array[Node3D]
@export var animation_tree: AnimationTree
@onready var locomotion_state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/LocomotionStateMachine/playback")
@onready var jump_state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/JumpStateMachine/playback")
@onready var laydown_state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/LayDownStateMachine/playback")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_window().grab_focus() # Necessary in case the window isn't in focus
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	for node in start_hidden:
		node.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	camera_movement_input_handler(delta)
	movement_animation_input_handler(delta)

## Input Management
# TODO: Separate this out into it's own input management system
# TODO: Input management system should account for controller and gamepad input
# TODO: Input management should also determin which controller icons are present in UI elements
enum InputMode {
	KEYBOARD_AND_MOUSE,
	GAMEPAD
}

var input_mode: InputMode

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		input_mode = InputMode.GAMEPAD
	
	if event is InputEventKey or event is InputEventMouseButton:
		input_mode = InputMode.KEYBOARD_AND_MOUSE
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion:
		var input_direction : Vector2 = event.relative.normalized()
		print(input_direction)
		var threshold : float = 0.8
		if input_direction.x < -threshold: Input.action_press("camera_left")
		if input_direction.x > threshold: Input.action_press("camera_right")
		if input_direction.y < -threshold: Input.action_press("camera_up")
		if input_direction.y > threshold: Input.action_press("camera_down")

func camera_movement_input_handler(delta: float) -> void:
	var input_vector : Vector2 = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	if input_vector != Vector2.ZERO: print("camera_movement: ", input_vector)
	
	if input_mode == InputMode.KEYBOARD_AND_MOUSE:
		Input.action_release("camera_up")
		Input.action_release("camera_down")
		Input.action_release("camera_left")
		Input.action_release("camera_right")

func movement_animation_input_handler(delta: float) -> void:
	var input_vector : Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	## TODO: Update this placeholder with physics.
	if input_vector != Vector2.ZERO:
		standup()
		
		if Input.is_action_pressed("locomotion_fast"):
			locomotion_state_machine.travel("Running")
		else:
			locomotion_state_machine.travel("Walking")
	else:
		locomotion_state_machine.travel("Idle")
	
	if Input.is_action_just_pressed("jump_button"): jump()
	if Input.is_action_just_pressed("action_button"): OneHanded_Ranged_Shot()
	if Input.is_action_just_pressed("interaction_button"): laydown()

## Utility Functions
func is_oneshot_busy() -> bool:
	return animation_tree.get("parameters/OneShot/active")

func transition(transition_name: String) -> bool:
	if is_oneshot_busy(): return false
	animation_tree.set("parameters/Transition/transition_request", transition_name)
	animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	return true

## Puppetry API
func movement(heading: Vector3, running : bool = true) -> void:
	pass

## TODO: Apply velocity for jump and manage falling automatically in _physics_process
## TODO: For now, landing is toggled via the button the instigated the jump sequence
var is_jumping: bool = false
func jump():
	if not transition("Jump"):
		if is_jumping:
			is_jumping = false
			jump_state_machine.travel("End")
		return
	
	is_jumping = true

var is_laying: bool = false
func laydown():
	if not transition("LayDown"): return
	is_laying = true

func standup():
	if not is_laying: return
	
	is_laying = false
	laydown_state_machine.travel("End")

func OneHanded_Ranged_Shot():
	if not transition("OneHanded_Ranged_Shot"): return
	
