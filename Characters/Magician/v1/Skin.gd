extends Node3D

@export var start_hidden: Array[Node3D]
@export var animation_player: AnimationPlayer
@export var animation_tree: AnimationTree
@onready var locomotion_state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/LocomotionStateMachine/playback")

func _ready() -> void:
	for node in start_hidden:
		node.visible = false


func consuming_animation() -> bool:
	for prop in animation_tree.get_property_list():
		if prop.name.begins_with("parameters/") and prop.name.ends_with("active"):
			if animation_tree.get(prop.name):
				return true
	return false

var laying_down : bool = false

func _input(event: InputEvent) -> void:
	#if event is InputEventKey and (event.is_pressed() or event.is_released()):
	if event is InputEventKey and event.is_released():
		if laying_down:
			laying_down = false
			animation_tree.get("parameters/LayingDownStateMachine/playback").travel("End")
			print("Pressed: ", event.as_text_key_label())
			return
		
		match event.keycode:
			KEY_Q:
				print("Pressed: ", event.as_text_key_label())
				if not consuming_animation():
					animation_tree.set("parameters/Transition/transition_request", "OneHanded_Ranged_Shot")
					animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		
			KEY_W:
				print("Pressed: ", event.as_text_key_label())
				if not consuming_animation():
					animation_tree.set("parameters/Transition/transition_request", "Jump")
					animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
					var timer = Timer.new()  # Create a new Timer instance
					timer.wait_time = 2.5    # Set to 5 seconds
					timer.one_shot = true    # Make it a one-shot timer
					add_child(timer)         # Add it to the scene tree
					timer.connect("timeout", _on_timer_timeout_jump)  # Connect the timeout signal
					timer.start()            # Start the timer
			
			KEY_E:
				print("Pressed: ", event.as_text_key_label())
				if not consuming_animation():
					animation_tree.get("parameters/LocomotionStateMachine/playback").travel("Walking")
			
			KEY_R:
				print("Pressed: ", event.as_text_key_label())
				if not consuming_animation():
					animation_tree.get("parameters/LocomotionStateMachine/playback").travel("Idle")
					
			KEY_A:
				print("Pressed: ", event.as_text_key_label())
				if not consuming_animation():
					animation_tree.get("parameters/LocomotionStateMachine/playback").travel("Running")


			KEY_S:
				print("Pressed: ", event.as_text_key_label())
				if not consuming_animation():
					animation_tree.set("parameters/Transition/transition_request", "LayingDown")
					animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
					var timer = Timer.new()  # Create a new Timer instance
					timer.wait_time = 2.5    # Set to 5 seconds
					timer.one_shot = true    # Make it a one-shot timer
					add_child(timer)         # Add it to the scene tree
					timer.connect("timeout", _on_timer_timeout_laydown)  # Connect the timeout signal
					timer.start()            # Start the timer

			KEY_D:
				print("Pressed: ", event.as_text_key_label())
				if not consuming_animation():
					laying_down = true
					animation_tree.set("parameters/Transition/transition_request", "LayingDown")
					animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			

func _on_timer_timeout_jump():
	#animation_tree.get("parameters/JumpStateMachine/playback").travel("Jump_Land")
	animation_tree.get("parameters/JumpStateMachine/playback").travel("End")

func _on_timer_timeout_laydown():
	#animation_tree.get("parameters/LayingDownStateMachine/playback").travel("Lie_StandUp")
	animation_tree.get("parameters/LayingDownStateMachine/playback").travel("End")
