@tool
extends BTAction

## Documentation: https://limboai.readthedocs.io/en/stable/getting-started/custom-tasks.html

@export var node_path: NodePath
@export var visible := true

func _generate_name() -> String:
	return "SetVisible  %s  node_path: \"%s\"" % [visible, node_path]
	
# Called to initialize the task.
func _setup() -> void:
	pass


# Called when the task is entered.
func _enter() -> void:
	pass


# Called when the task is exited.
func _exit() -> void:
	pass


# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	print("********")
	return SUCCESS


# Strings returned from this method are displayed as warnings in the editor.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	return warnings
