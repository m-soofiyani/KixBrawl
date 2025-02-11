extends Node

class_name GameMatch

var selected_port:int
var port_min := 8082
var port_max := 8900
var rand_port : int
var matchinfo : Array
#selecting random port needs fix
func _init() -> void:
	rand_port = select_port()
	while Ports.UsedPorts.has(rand_port):
		rand_port = select_port()
	
	selected_port = rand_port
	Ports.UsedPorts.append(selected_port)
	print("match created with port: " + str(selected_port))
		

func select_port():
	return range(port_min , port_max).pick_random()


func _exit_tree() -> void:
	Ports.UsedPorts.erase(selected_port)
