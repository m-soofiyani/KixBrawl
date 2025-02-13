extends Node

var UsedPorts : Array


func AddPort(port):
	UsedPorts.append(port)
	
	
func RemovePort(port):
	UsedPorts.erase(port)
	
func HasPort(port) -> bool:
	return UsedPorts.has(port)
