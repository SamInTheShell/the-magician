extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var connected_joypads = Input.get_connected_joypads()
	for joypad_id in connected_joypads:
		var name = Input.get_joy_name(joypad_id)  # Get the controller's name
		print("Controller ID:", joypad_id, " Name:", name)

	Global.update_device_number(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_device_number(new_device_number: int) -> void:
	var action_list = InputMap.get_actions()
	
	for action_name in action_list:
		var events = InputMap.action_get_events(action_name)
		
		for event in events:
			var updated_event = event.duplicate()
			updated_event.device = new_device_number
			
			InputMap.action_erase_event(action_name, event)
			InputMap.action_add_event(action_name, updated_event)
	
