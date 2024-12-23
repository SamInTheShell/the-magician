extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_window().grab_focus() # Necessary in case the window isn't in focus
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var connected_joypads = Input.get_connected_joypads()
	for joypad_id in connected_joypads:
		var joypad_name = Input.get_joy_name(joypad_id)  # Get the controller's name
		print("Controller ID:", joypad_id, " Name:", joypad_name)

	Global.update_device_number(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func update_device_number(new_device_number: int) -> void:
	var action_list = InputMap.get_actions()
	
	for action_name in action_list:
		var events = InputMap.action_get_events(action_name)
		
		for event in events:
			var updated_event = event.duplicate()
			updated_event.device = new_device_number
			
			InputMap.action_erase_event(action_name, event)
			InputMap.action_add_event(action_name, updated_event)

## Input hacks
var input_mode: InputMode

enum InputMode {
	KEYBOARD_AND_MOUSE,
	GAMEPAD
}

func get_camera_input_vector() -> Vector2:
	var input_vector : Vector2 = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down")
	
	if input_mode == InputMode.KEYBOARD_AND_MOUSE:
		Input.action_release("camera_up")
		Input.action_release("camera_down")
		Input.action_release("camera_left")
		Input.action_release("camera_right")

	return input_vector

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		input_mode = InputMode.GAMEPAD
	
	if event is InputEventKey or event is InputEventMouseButton:
		input_mode = InputMode.KEYBOARD_AND_MOUSE
	
	## Virtual mapping of mouse movement to match right thumbstick input
	if event is InputEventMouseMotion:
		var input_direction : Vector2 = event.relative.normalized()
		## TODO: Values are typically pretty high...
		# this may need to be adjustable due to differences in mouse DPI?
		var threshold : float = 0.8
		## TODO: Mouse input is trash?
		if input_direction.x < -threshold: Input.action_press("camera_left")
		if input_direction.x > threshold: Input.action_press("camera_right")
		if input_direction.y < -threshold: Input.action_press("camera_up")
		if input_direction.y > threshold: Input.action_press("camera_down")
