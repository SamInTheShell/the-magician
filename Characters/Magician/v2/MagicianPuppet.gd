#@tool
extends Node3D

class_name MagicianPuppet

@export var start_hidden: Array[Node3D]
@export var animation_tree: AnimationTree
@onready var locomotion_state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/LocomotionStateMachine/playback")
@onready var jump_state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/JumpStateMachine/playback")
@onready var laydown_state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/LayDownStateMachine/playback")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in start_hidden:
		node.visible = false


## Utility Functions
func is_oneshot_busy() -> bool:
	return animation_tree.get("parameters/OneShot/active")

func transition(transition_name: String) -> bool:
	if is_oneshot_busy(): return false
	animation_tree.set("parameters/Transition/transition_request", transition_name)
	animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	return true

## Puppetry API

## TODO: Cleanup later
#func trigger_bro():
	#var bb = $BTPlayer.get_blackboard() as Blackboard
	#print("set_var for trigger_bro=true")
	#bb.set_var("trigger_bro", true)

func movement(_heading: Vector3, _running : bool = true) -> void:
	pass

## TODO: Apply velocity for jump and manage falling automatically in _physics_process
## TODO: For now, landing is toggled via the button the instigated the jump sequence
var is_jumping: bool = false
func jump() -> void:
	if not transition("Jump"): return landing()
	
	is_jumping = true

func landing() -> void:
	if not is_jumping: return
	is_jumping = false
	jump_state_machine.travel("End")

var is_laying: bool = false
func laydown() -> void:
	if not transition("LayDown"): return
	is_laying = true

func standup() -> void:
	if not is_laying: return
	
	is_laying = false
	laydown_state_machine.travel("End")

func OneHanded_Ranged_Shot() -> void:
	if not transition("OneHanded_Ranged_Shot"): return
	
