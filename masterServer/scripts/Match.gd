extends Node

class_name GameMatch

var selected_port:int
var port_min := 8082
var port_max := 9000


var matchinfo : Array
#selecting random port needs fix
func _init() -> void:
	selected_port = select_unique_port()
	if selected_port == -1:
		push_error("No available ports in the range!")
		return

	# Add the selected port to the list of used ports
	PortManager.AddPort(selected_port)
	print("Match created with port: ", selected_port)

func select_unique_port() -> int:
	var attempts = 0
	var max_attempts = port_max - port_min

	while attempts < max_attempts:
		var port = randi_range(port_min, port_max)
		if not PortManager.HasPort(port):
			return port
		attempts += 1

	# If no available port is found, return -1
	return -1


func _exit_tree() -> void:
	PortManager.RemovePort(selected_port)
	print("Match destroyed, port freed: ", selected_port)
